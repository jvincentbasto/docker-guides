import express from "express";
import controllerAnime from "../controllers/anime.js";

const router = express.Router();

router.get("/", controllerAnime.getAll);
router.post("/", controllerAnime.create);

export default router;
