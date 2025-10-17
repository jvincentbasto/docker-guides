import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import colors from "colors";

import connect from "./src/database/connect.js";
import animeRouter from "./src/routes/anime.js";

// envs
const isProduction = process.env.NODE_ENV === "production";
const envFile = isProduction ? ".env" : ".env.local";
dotenv.config({ path: envFile });
const port = process.env.PORT || 8000;

// setup
colors.enable();
const app = express();
app.use(
  cors({
    origin: "*",
  })
);
app.use(express.json());

// routes
app.get("/", (req, res) => {
  const env = isProduction ? "Production".green : "Development".blue;
  console.log("Environment", env);
  res.send("Hello World!");
});
// k8s probes
app.get("/readyz", (req, res) => {
  return res.status(200).send("ready");
});
app.get("/healthz", (req, res) => {
  return res.status(200).send("ok");
});
// resource routes
app.use("/api/anime", animeRouter);

app.listen(port, () => {
  const url = isProduction
    ? `http://localhost:${port}`.green
    : `http://localhost:${port}`.blue;
  console.log(`Server listening on ${url}`);
  connect();
});
