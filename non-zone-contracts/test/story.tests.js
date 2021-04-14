const { assert, expect } = require("chai");

const StoryFactory = artifacts.require("StoryFactory");
const StoryInteractionFactory = artifacts.require("StoryInteractionFactory");

contract("StoryFactory", async accounts => {
    it("should create a story", async () => {
        const instance = await StoryFactory.deployed();

        const accountBalanceBefore = await instance.balanceOf(accounts[0]);

        await instance.createStory('http://something.com/something.json');

        const accountBalanceAfter = await instance.balanceOf(accounts[0]);

        expect(accountBalanceBefore.valueOf().toString()).to.be.equal('0');
        expect(accountBalanceAfter.valueOf().toString()).to.be.equal('1');

    });
});
contract("StoryInteractionFactory", async accounts => {

    it("should create a child story and open a stream if there are free spots left", async () => {
        const storyFactory = await StoryFactory.deployed();
        const storyInstanceFactory = await StoryInteractionFactory.deployed();

        await storyFactory.createStory(
            'http://something.com/something.json',
            { from: accounts[1] }
        );

        await storyInstanceFactory.createStoryInteraction(
            'http://something.com/something.json',
            0,
            { from: accounts[2] }
        );

        const activeStreams = await storyInstanceFactory.activeStreamsCount();
        const storyBalance = await storyFactory.balanceOf(accounts[1]);
        const storyInteractionBalance = await storyInstanceFactory.balanceOf(accounts[2]);
        const hasStreamStarted = await storyInstanceFactory.startedStream(accounts[1]);

        expect(activeStreams.valueOf().toString()).to.be.equal('1');
        expect(storyBalance.valueOf().toString()).to.be.equal('1');
        expect(storyInteractionBalance.valueOf().toString()).to.be.equal('1');
        expect(hasStreamStarted.valueOf()).to.be.true;
    });

    it("should not open a stream if it's already opened for this story", async () => {
        const storyFactory = await StoryFactory.deployed();
        const storyInstanceFactory = await StoryInteractionFactory.deployed();

        await storyInstanceFactory.createStoryInteraction(
            'http://something.com/something.json',
            0,
            { from: accounts[9] }

        );

        let activeStreams = await storyInstanceFactory.activeStreamsCount();
        let accountBalance = await storyInstanceFactory.balanceOf(accounts[9]);
        const hasStreamStarted = await storyInstanceFactory.startedStream(accounts[1]);

        expect(activeStreams.valueOf().toString()).to.be.equal('1');
        expect(hasStreamStarted.valueOf()).to.be.true;
        expect(accountBalance.valueOf().toString()).to.be.equal('1');

        await storyInstanceFactory.createStoryInteraction(
            'http://something.com/something.json',
            0,
            { from: accounts[5] }
        );

        activeStreams = await storyInstanceFactory.activeStreamsCount();
        accountBalance = await storyInstanceFactory.balanceOf(accounts[5]);


        expect(activeStreams.valueOf().toString()).to.be.equal('1');
        expect(accountBalance.valueOf().toString()).to.be.equal('1');
    });


    it("should not open a stream if story owner interacts with their own story", async () => {
        const storyInstanceFactory = await StoryInteractionFactory.deployed();

        try {
            await storyInstanceFactory.createStoryInteraction(
                'http://something.com/something.json',
                0,
                { from: accounts[1] }
            )
            expect(true).to.eq('Did not throw');
        } catch (err) {
            expect(err.message.includes('The owner of the story is not allowed to interact with their own stories')).to.be.true;
        }

    });
});