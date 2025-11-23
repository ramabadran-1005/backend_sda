const fs = require("fs");
const path = require("path");

// Build the full path
const modelPath = path.resolve(
  __dirname,
  "ml",
  "saved_models",
  "model_tfjs",
  "model.json"
);

console.log("Checking for model.json at:", modelPath);

// Check if the file exists
fs.access(modelPath, fs.constants.F_OK, (err) => {
  if (err) {
    console.error("❌ model.json NOT FOUND!");
  } else {
    console.log("✅ model.json FOUND!");
  }
});
