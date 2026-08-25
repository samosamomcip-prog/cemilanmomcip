const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const app = fs.readFileSync('app.js', 'utf8');
const index = fs.readFileSync('index.html', 'utf8');
new vm.Script(app, { filename: 'app.js' });

function extractFunction(source, name) {
  const start = source.indexOf(`function ${name}(`);
  assert.ok(start >= 0, `function ${name} was not found`);
  const brace = source.indexOf('{', start);
  let depth = 0;
  for (let i = brace; i < source.length; i += 1) {
    if (source[i] === '{') depth += 1;
    else if (source[i] === '}') {
      depth -= 1;
      if (depth === 0) return source.slice(start, i + 1);
    }
  }
  throw new Error(`function ${name} is incomplete`);
}

const elements = new Map();
const document = {
  activeElement: null,
  getElementById: id => elements.get(id) || null,
};
class FakeElement {
  constructor(id, value, type = 'text') {
    this.id = id;
    this.value = value;
    this.type = type;
    this.checked = false;
    this.selectionStart = String(value).length;
    this.selectionEnd = String(value).length;
  }
  focus() { document.activeElement = this; }
  setSelectionRange(start, end) {
    this.selectionStart = start;
    this.selectionEnd = end;
  }
}
const root = {
  querySelectorAll: () => [...elements.values()].filter(x => x.id !== 'order'),
  contains: element => [...elements.values()].includes(element),
};
elements.set('order', root);
elements.set('oCustomer', new FakeElement('oCustomer', 'Pelanggan Sedang Diketik'));
elements.set('oQty', new FakeElement('oQty', '7', 'number'));
elements.set('oType', new FakeElement('oType', 'RESELLER', 'select-one'));
elements.get('oCustomer').focus();
elements.get('oCustomer').setSelectionRange(4, 12);

const context = vm.createContext({ document, Object, JSON, Boolean, console });
const auditKeys = app.match(/const NORMALIZED_AUDIT_KEYS=new Set\([^\n]+/);
assert.ok(auditKeys, 'audit key definition was not found');
vm.runInContext([
  auditKeys[0],
  extractFunction(app, 'sameValue'),
  extractFunction(app, 'mergeConcurrentRow'),
  extractFunction(app, 'captureFormState'),
  extractFunction(app, 'restoreFormState'),
].join('\n'), context);

const state = context.captureFormState('order');
elements.get('oCustomer').value = '';
elements.get('oQty').value = '1';
elements.get('oType').value = 'REGULER';
document.activeElement = null;
context.restoreFormState(state);

assert.equal(elements.get('oCustomer').value, 'Pelanggan Sedang Diketik');
assert.equal(elements.get('oQty').value, '7');
assert.equal(elements.get('oType').value, 'RESELLER');
assert.equal(document.activeElement.id, 'oCustomer');
assert.equal(elements.get('oCustomer').selectionStart, 4);
assert.equal(elements.get('oCustomer').selectionEnd, 12);

const base = { id: '1', customer: 'A', status: 'Baru', created_by_name: 'Karel' };
const remote = { id: '1', customer: 'A', status: 'Selesai', created_by_name: 'Karel' };
const local = { id: '1', customer: 'B', status: 'Baru', created_by_name: 'Karel' };
const nonConflict = context.mergeConcurrentRow(base, remote, local);
assert.equal(nonConflict.merged.customer, 'B');
assert.equal(nonConflict.merged.status, 'Selesai');
assert.deepEqual(Array.from(nonConflict.conflicts), []);

const conflict = context.mergeConcurrentRow(base, { ...remote, customer: 'C' }, local);
assert.equal(conflict.merged.customer, 'C');
assert.ok(Array.from(conflict.conflicts).includes('customer'));

assert.match(app, /const APP_VERSION='8\.0\.0'/);
assert.match(index, /v8\.0/);
assert.ok(!index.includes('location.reload()'), 'service worker must not force-reload an active form');

console.log('PASS: V8 syntax, form preservation, version, and concurrent-row merge');

