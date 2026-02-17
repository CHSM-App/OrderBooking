const express = require("express");
const axios = require("axios");

const router = express.Router();

const GRAPHOPPER_KEY = "c2453a3b-31a1-4c38-b65e-55514d645ce4";
const MAX_POINTS = 5;
const MAX_RETRY = 3;



/**
 * Create continuous batches
 * Example:
 * [A,B,C,D,E,F,G]
 * =>
 * [A,B,C,D,E]
 * [E,F,G]
 */
function createBatches(coords) {

    const batches = [];

    let i = 0;

    while (i < coords.length - 1) {

        const batch = coords.slice(i, i + MAX_POINTS);

        batches.push(batch);

        i += MAX_POINTS - 1;

    }

    return batches;

}



/**
 * Call Graphhopper API with retry
 */
async function callGraphhopper(points, retry = 0) {

    try {

        let url = `https://graphhopper.com/api/1/route?profile=car&points_encoded=false&key=${GRAPHOPPER_KEY}`;

        points.forEach(p => {
            url += `&point=${p}`;
        });


        const response = await axios.get(url, {
            timeout: 10000
        });


        return {

            distance: response.data.paths[0].distance,

            time: response.data.paths[0].time

        };

    }

    catch (error) {

        if (retry < MAX_RETRY) {

            console.log(`Retry ${retry + 1}...`);

            return callGraphhopper(points, retry + 1);

        }

        throw error;

    }

}

module.exports = {
    createBatches,
    callGraphhopper,
};
