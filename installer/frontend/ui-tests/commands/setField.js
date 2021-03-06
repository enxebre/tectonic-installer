// Simply sets a field's value then asserts that the field actually changed to that value
exports.command = function(selector, value, clearFirst = false) {
  this.expect.element(selector).to.be.visible;
  if (clearFirst) {
    this.clearValue(selector);
    this.expect.element(selector).to.have.value.that.equals('');
  }
  this.setValue(selector, value);
  this.expect.element(selector).to.have.value.that.equals(value);
};
