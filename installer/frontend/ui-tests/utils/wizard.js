const nextStep = '.wiz-form__actions__next button.btn-primary';
const prevStep = 'button.wiz-form__actions__prev';

const testPage = (page, json, nextInitiallyDisabled = true) => {
  page.expect.element(prevStep).to.be.visible;
  page.expect.element(prevStep).to.not.have.attribute('class').which.contains('disabled');

  page.expect.element(nextStep).to.be.visible;
  if (nextInitiallyDisabled) {
    page.expect.element(nextStep).to.have.attribute('class').which.contains('disabled');
  }

  // Sidebar link for the current page should be highlighted and enabled
  page.expect.element('.wiz-wizard__nav__step--active button').to.not.have.attribute('disabled');

  // The next sidebar links should be disabled if the next button is disabled
  const nextNavLink = page.expect.element('.wiz-wizard__nav__step--active + .wiz-wizard__nav__step button');
  if (nextInitiallyDisabled) {
    nextNavLink.to.have.attribute('disabled');
  } else {
    nextNavLink.to.not.have.attribute('disabled');
  }

  if (page.test) {
    page.test(json);
  }
  page.waitForElementNotPresent(`${nextStep}.disabled`);
  page.expect.element(nextStep).to.have.attribute('class').which.not.contains('disabled');
  return page.click(nextStep);
};

module.exports = {
  nextStep,
  prevStep,
  testPage,
};
