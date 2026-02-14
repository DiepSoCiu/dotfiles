"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SKELETON_NAMES = exports.Skeleton = void 0;
const basepettype_1 = require("../basepettype");
const states_1 = require("../states");
const getRandomElement = (array) => {
    const randomIndex = Math.floor(Math.random() * array.length);
    return array[randomIndex];
};
class Skeleton extends basepettype_1.BasePetType {
    constructor(spriteElement, collisionElement, speechElement, size, left, bottom, petRoot, floor, name, speed) {
        // Replace spaces with underscores
        // Keeps file names consistent
        const petRootClean = petRoot.replace(' ', '_');
        super(spriteElement, collisionElement, speechElement, size, left, bottom, petRootClean, floor, name, speed);
    }
    label = 'skeleton';
    static possibleColors = [
        "white" /* PetColor.white */,
        "brown" /* PetColor.brown */,
        "purple" /* PetColor.purple */,
        "blue" /* PetColor.blue */,
        "pink" /* PetColor.pink */,
        "yellow" /* PetColor.yellow */,
        "green" /* PetColor.green */,
        "red" /* PetColor.red */,
        "orange" /* PetColor.orange */,
        "warrior" /* PetColor.warrior */,
    ];
    sequence = {
        startingState: "stand-right" /* States.standRight */,
        sequenceStates: [
            {
                state: "sit-idle" /* States.sitIdle */,
                // Only on first adding the skeleton
                possibleNextStates: ["walk-right" /* States.walkRight */],
            },
            {
                state: "stand-right" /* States.standRight */,
                // Can start walking either direction (twice as likely to keep going right), or just keep standing
                possibleNextStates: [
                    "walk-right" /* States.walkRight */,
                    "walk-right" /* States.walkRight */,
                    "walk-left" /* States.walkLeft */,
                    "stand-right" /* States.standRight */,
                ],
            },
            {
                state: "stand-left" /* States.standLeft */,
                // Can start walking either direction (twice as likely to keep going left), or just keep standing
                possibleNextStates: [
                    "walk-right" /* States.walkRight */,
                    "walk-left" /* States.walkLeft */,
                    "walk-left" /* States.walkLeft */,
                    "stand-left" /* States.standLeft */,
                ],
            },
            {
                state: "walk-right" /* States.walkRight */,
                // Can switch directions or stand still
                possibleNextStates: ["walk-left" /* States.walkLeft */, "stand-right" /* States.standRight */],
            },
            {
                state: "walk-left" /* States.walkLeft */,
                // Can switch directions or stand still
                possibleNextStates: ["walk-right" /* States.walkRight */, "stand-left" /* States.standLeft */],
            },
            {
                state: "chase" /* States.chase */,
                // After the chase, the skeleton has the ball!
                possibleNextStates: ["idle-with-ball" /* States.idleWithBall */],
            },
            {
                state: "swipe" /* States.swipe */,
                possibleNextStates: ["sit-idle" /* States.sitIdle */],
            },
            {
                state: "idle-with-ball" /* States.idleWithBall */,
                // Can go back to walking
                possibleNextStates: ["walk-right" /* States.walkRight */, "walk-left" /* States.walkLeft */],
            },
        ],
    };
    get emoji() {
        if (this.name.toLowerCase() === 'beau') {
            return '🤡';
        }
        if (this.petRoot.endsWith('warrior')) {
            return getRandomElement(['🗡️', '🏴‍☠️', '⚔️']);
        }
        return '💀';
    }
    get hello() {
        let response = 'Bone to be Wild!';
        switch (this.name.toLowerCase()) {
            case 'crypt keeper':
                response = 'Hello, kiddies!';
                break;
            case 'hugo':
                response = "I'm the world's laziest skeleton!";
                break;
            case 'skeletor':
                response = 'I have the power!';
                break;
            case 'jack skellington':
                response = 'Eureka! Merry Christmas!';
                break;
            case 'scorpion':
                response = 'Get over here!';
                break;
            case 'walter donovan':
                response = 'Choose wisely.';
                break;
        }
        if (this.petRoot.endsWith('warrior')) {
            response = response.toUpperCase();
        }
        if (this.name.toLowerCase() === 'warner') {
            return `💜 ${response} 🧡`;
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
        this.showSpeechBubble(this.petRoot.endsWith('orange')
            ? '🎃'
            : this.petRoot.endsWith('warrior')
                ? '🏴‍☠️'
                : '☠️');
    }
    chooseNextState(fromState) {
        const nextState = super.chooseNextState(fromState);
        if (this.name.toLowerCase() === 'debug') {
            console.log(`${this.label}-> \x1b[1m${nextState}\x1b[0m`);
        }
        return nextState;
    }
}
exports.Skeleton = Skeleton;
exports.SKELETON_NAMES = [
    'Sans',
    'Papyrus',
    'Red Skull',
    'Ghost Rider',
    'Skeletor',
    'Jack Skellington',
    'Grim',
    'Brook',
    'Bonejangles',
    'Smitty Werbenjagermanjensen',
    'The Lich',
    'Crypt Keeper',
    'Scorpion',
    'Eddie',
    'Mister Bones',
    'Imhotep',
    'Nito',
    'Spinal',
    'Geoff Peterson',
    'Horrorman',
    'Baron Samedi',
    'Skelly',
    'Yorick',
    'Lucy',
    'Hugo',
    'The Horned King',
    'Walter Donovan',
    'Sherlock Bones',
    'Napolean Bone-aparte',
    'Skellyman',
];
//# sourceMappingURL=skeleton.js.map