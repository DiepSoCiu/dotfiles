"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SQUIRREL_NAMES = exports.Squirrel = void 0;
const basepettype_1 = require("../basepettype");
const states_1 = require("../states");
const getRandomIntegerInRange = (low, high) => {
    if (low > high) {
        [low, high] = [high, low]; // swapsies!
    }
    const min = Math.ceil(low);
    const max = Math.floor(high);
    return Math.floor(Math.random() * (max - min + 1)) + min;
};
const getRandomElement = (array) => {
    const randomIndex = getRandomIntegerInRange(0, array.length - 1);
    return array[randomIndex];
};
class Squirrel extends basepettype_1.BasePetType {
    _resizeListener;
    constructor(spriteElement, collisionElement, speechElement, size, left, bottom, petRoot, floor, name, speed) {
        // Replace spaces with underscores
        // Keeps file names consistent
        const petRootClean = petRoot.replace(' ', '_');
        super(spriteElement, collisionElement, speechElement, size, left, bottom, petRootClean, floor, name, speed * 1.15);
        this._climbSpeed = 7;
        this._fallSpeed = 15;
        this._resizeListener = () => {
            this.adjustClimbHeight();
        };
        window.addEventListener('resize', this._resizeListener);
        this.adjustClimbHeight();
    }
    label = 'squirrel';
    static possibleColors = [
        "gray" /* PetColor.gray */,
        "black" /* PetColor.black */,
        "brown" /* PetColor.brown */,
        "purple" /* PetColor.purple */,
        "white" /* PetColor.white */,
    ];
    sequence = {
        startingState: "sit-idle" /* States.sitIdle */,
        sequenceStates: [
            {
                state: "sit-idle" /* States.sitIdle */,
                possibleNextStates: ["walk-right" /* States.walkRight */, "walk-left" /* States.walkLeft */],
            },
            {
                state: "stand-right" /* States.standRight */,
                // Can start walking either direction, or run to the right
                possibleNextStates: [
                    "walk-right" /* States.walkRight */,
                    "run-right" /* States.runRight */,
                    "walk-left" /* States.walkLeft */,
                ],
            },
            {
                state: "stand-left" /* States.standLeft */,
                // Can start walking either direction, or run to the left
                possibleNextStates: [
                    "walk-left" /* States.walkLeft */,
                    "run-left" /* States.runLeft */,
                    "walk-right" /* States.walkRight */,
                    "climb-wall-left" /* States.climbWallLeft */,
                ],
            },
            {
                state: "walk-right" /* States.walkRight */,
                // Can stand, start running, or switch directions
                possibleNextStates: [
                    "stand-right" /* States.standRight */,
                    "run-right" /* States.runRight */,
                    "walk-left" /* States.walkLeft */,
                    "walk-right" /* States.walkRight */,
                ],
            },
            {
                state: "walk-left" /* States.walkLeft */,
                // Can stand, start running, or switch directions
                possibleNextStates: [
                    "stand-left" /* States.standLeft */,
                    "run-left" /* States.runLeft */,
                    "climb-wall-left" /* States.climbWallLeft */,
                    "walk-right" /* States.walkRight */,
                    "walk-left" /* States.walkLeft */,
                ],
            },
            {
                state: "run-right" /* States.runRight */,
                // Can switch directions or slow down to a walk (twice as likely), or even abruptly stop to eat
                possibleNextStates: [
                    "run-left" /* States.runLeft */,
                    "walk-right" /* States.walkRight */,
                    "walk-right" /* States.walkRight */,
                    "stand-right" /* States.standRight */,
                ],
            },
            {
                state: "run-left" /* States.runLeft */,
                // Can switch directions or slow down to a walk (twice as likely), or even abruptly stop to eat
                possibleNextStates: [
                    "run-right" /* States.runRight */,
                    "walk-left" /* States.walkLeft */,
                    "walk-left" /* States.walkLeft */,
                    "stand-left" /* States.standLeft */,
                    "climb-wall-left" /* States.climbWallLeft */,
                ],
            },
            {
                state: "climb-wall-left" /* States.climbWallLeft */,
                possibleNextStates: ["wall-dig-left" /* States.wallDigLeft */],
            },
            {
                state: "wall-dig-left" /* States.wallDigLeft */,
                possibleNextStates: ["wall-nap" /* States.wallNap */],
            },
            {
                state: "wall-nap" /* States.wallNap */,
                possibleNextStates: ["wall-hang-left" /* States.wallHangLeft */],
            },
            {
                state: "wall-hang-left" /* States.wallHangLeft */,
                possibleNextStates: ["jump-down-left" /* States.jumpDownLeft */],
            },
            {
                state: "jump-down-left" /* States.jumpDownLeft */,
                possibleNextStates: ["land" /* States.land */],
            },
            {
                state: "land" /* States.land */,
                possibleNextStates: ["sit-idle" /* States.sitIdle */, "run-right" /* States.runRight */],
            },
            {
                state: "chase" /* States.chase */,
                // After the chase, the squirrel has the ball!
                possibleNextStates: ["idle-with-ball" /* States.idleWithBall */],
            },
            {
                state: "swipe" /* States.swipe */,
                possibleNextStates: ["sit-idle" /* States.sitIdle */],
            },
            {
                state: "idle-with-ball" /* States.idleWithBall */,
                // Eat the ball, then go back to running
                possibleNextStates: ["run-right" /* States.runRight */, "run-left" /* States.runLeft */],
            },
        ],
    };
    get emoji() {
        return '🐿️';
    }
    get hello() {
        let response = 'Got any nuts?!';
        switch (this.name.toLowerCase()) {
            case 'bruce':
                response = "Wanna get nuts? Let's get nuts!";
                break;
            case 'hugo':
                response = "I'm the world's laziest squirrel!";
                break;
            case 'rocky':
                response = 'Oh, Bullwinkle! You did it again!';
                break;
            case 'slappy':
                response = 'You remind me of...';
                break;
            case 'bucky':
                response = '🎈🪡? 🐆🐆';
                break;
            case 'sandy':
                response = 'I don’t cry, I sweat through my eyes!';
                break;
            case 'sinan':
            case 'twiggy':
                response = 'Go Vols! 🍊';
                break;
            case 'charlie':
                response = 'Charie DO know!';
                break;
            case 'noah':
                response = 'Is that a 🌧️🌎 reference?';
                break;
            case 'eleanor':
                response = 'Meow?';
                break;
        }
        return response;
    }
    swipe() {
        if (this.currentStateEnum === "swipe" /* States.swipe */) {
            return;
        }
        this.holdState = this.currentState;
        this.holdStateEnum = this.currentStateEnum;
        this.currentStateEnum = "swipe" /* States.swipe */;
        this.currentState = (0, states_1.resolveState)(this.currentStateEnum, this);
        const food = getRandomElement(['🌰', '🍕', '🥨', '🥜', '🥡', '🍏']);
        this.showSpeechBubble(`${food}?`);
    }
    chooseNextState(fromState) {
        const nextState = super.chooseNextState(fromState);
        if (this.name.toLowerCase() === 'debug') {
            console.log(`${this.label}-> \x1b[1m${nextState}\x1b[0m`);
        }
        return nextState;
    }
    _variation = 0;
    _variationCounter = 0;
    _variationTimer = 10;
    get climbSpeed() {
        this._variationCounter++;
        if (this._variationCounter >= this._variationTimer) {
            // random number between -4 and +1
            this._variation = Math.floor(Math.random() * 6) - 4;
            // random number between 10 and 25
            this._variationTimer = Math.floor(Math.random() * 16) + 10;
            this._variationCounter = 0;
        }
        return this._climbSpeed + this._variation;
    }
    adjustClimbHeight() {
        const viewportHeight = window.innerHeight;
        const elementHeight = this.calculateSpriteWidth(this.size);
        // Scale the climb height based on viewport height
        const minHeight = Math.floor(viewportHeight * 0.3);
        const maxHeight = Math.floor(viewportHeight * 0.8);
        this._climbHeight = getRandomIntegerInRange(Math.max(elementHeight * 2, minHeight), Math.min(viewportHeight - elementHeight, maxHeight));
        if (this.name.toLowerCase() === 'debug') {
            console.log(`Squirrel ${this.name} adjusted climb height to ${this._climbHeight} (viewport: ${viewportHeight}, element: ${elementHeight})`);
        }
    }
    remove() {
        if (this._resizeListener) {
            window.removeEventListener('resize', this._resizeListener);
            this._resizeListener = undefined;
        }
        super.remove();
    }
}
exports.Squirrel = Squirrel;
exports.SQUIRREL_NAMES = [
    'Twiggy',
    'Scrat',
    'Rocky',
    'Sandy',
    'Secret Squirrel',
    'Slappy',
    'Skippy',
    'Conker',
    'Bucky',
    'Guinevere',
    'Sally',
    'Chitter',
    'Squeaks',
    'Sinan',
    'Nutsy',
    'Lady Timbertail',
    'Nibbles',
    'Nutty',
    'Twitchy',
    'Nutkin',
    'Acornelia',
    'Sneezy',
    'Scamper',
    'Peanut',
    'Eleanor',
    'Acorn',
    'Bruce',
    'Walnut',
    'Hazel',
    'Noah',
    'Henry',
    'Ranger',
    'Link',
    'Tomato',
    'Charlie',
    'Pinecone',
];
//# sourceMappingURL=squirrel.js.map