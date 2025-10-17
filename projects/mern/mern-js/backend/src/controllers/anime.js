import Anime from "../models/Anime.js";

const getAll = async (req, res) => {
  try {
    const anime = await Anime.find();
    return res.json(anime);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Failed to fetch anime" });
  }
};
const create = async (req, res) => {
  try {
    const anime = new Anime(req.body);
    await anime.save();
    return res.status(201).json(anime);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Failed to create anime" });
  }
};

export default {
  getAll,
  create,
};
