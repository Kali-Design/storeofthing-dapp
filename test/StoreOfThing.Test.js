/* eslint-disable no-unused-expressions */
const { accounts, contract } = require('@openzeppelin/test-environment');
const { time } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const StoreOfThing = contract.fromArtifact('StoreOfThing');

describe('StoreOfThing', async function () {
  const [dev, owner, user1] = accounts;
  const MESSAGE = 'WELCOME TO MY COURSES';
  const _MESSAGE = 'NEW MESSAGE';

  context('StoreOfThing initial state', function () {
    
    beforeEach(async function () {
      this.storeofthing = await StoreOfThing.new(owner, MESSAGE, { from: dev });
    });

    it(`has message ${MESSAGE}`, async function () {
      expect(await this.storeofthing.getMessage()).to.equal(MESSAGE);
    });

    it('has owner', async function () {
      expect(await this.storeofthing.owner()).to.equal(owner);
    });

    it('has starting date', async function () {
      const _current = await time.latest();
      expect(await this.storeofthing.getStartDate()).to.be.a.bignumber.equal(_current);
    });
  });

  context('StoreOfThing ownership', function () {
    beforeEach(async function () {
      this.storeofthing = await this.storeofthing.new(owner, MESSAGE, { from: dev });
    });
    it('set message', async function () {
      await this.storeofthing.setMessage(_MESSAGE, { from: owner });
      expect(await this.storeofthing.getMessage()).to.equal(_MESSAGE);
    });
  });
  context('StoreOfThing time functions', function () {
    beforeEach(async function () {
      this.account = await StoreOfThing.new(owner, MESSAGE, { from: dev });
    });
    it('handles not finished yet', async function () {
      expect(await this.storeofthing.goodbye({ from: user1 })).to.equal('not finished yet!!');
    });

    it('handles finished courses', async function () {
      await time.increase(time.duration.weeks(24));
      expect(await StoreOfThing.goodbye({ from: user1 })).to.equal('congratulations and goodbye!!');
    });
  });
});
