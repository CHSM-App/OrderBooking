const express = require("express");
const axios = require("axios");
const polylineUtil = require('@mapbox/polyline');
require('dotenv').config();

const router = express.Router();

const MAX_POINTS = 10;

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



async function callGoogleDirections(points, retry = 0) {
        console.log(`inside the callGoogleDirections with points: ${points}`);
    try {

        if (points.length < 2) {
            throw new Error("Minimum 2 points required");
        }

        const origin = points[0];
        const destination = points[points.length - 1];

        const waypoints = points
            .slice(1, points.length - 1)
            .join("|");

        let url = `https://maps.googleapis.com/maps/api/directions/json` +
            `?origin=${origin}` +
            `&destination=${destination}` +
            `&mode=driving` +
            `&key=${process.env.GOOGLE_MAP_DIRECTIONS_API_KEY}`;

            
            if (waypoints.length > 0) {
                url += `&waypoints=${waypoints}`;
            }
            
            console.log(url);
            
        const response = await axios.get(url, {
            timeout: 10000
        });

        console.log("Google Response:", JSON.stringify(response.data, null, 2));

        const route = response.data.routes[0];

        let totalDistance = 0;
        let totalDuration = 0;

        route.legs.forEach(leg => {
            totalDistance += leg.distance.value;   // meters
            totalDuration += leg.duration.value;   // seconds
        });

        return {
            distance: totalDistance,        // meters
            duration: totalDuration,        // seconds
            polyline: route.overview_polyline.points
        };

    } catch (error) {

        if (retry < MAX_RETRY) {
            console.log(`Retry ${retry + 1}...`);
            return callGoogleDirections(points, retry + 1);
        }

        throw error;
    }
}


function mergePolylines(encodedPolylines) {

  let finalCoordinates = [];

  encodedPolylines.forEach((encoded, index) => {

    const decoded = polylineUtil.decode(encoded);

    // Remove duplicate join point except first batch
    if (index > 0) {
      decoded.shift();
    }

    finalCoordinates = finalCoordinates.concat(decoded);
  });

  return polylineUtil.encode(finalCoordinates);
}

module.exports = {
    createBatches,
    callGoogleDirections,
    mergePolylines
};




