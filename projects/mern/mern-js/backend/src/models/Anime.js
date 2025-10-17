import mongoose from "mongoose";

const AnimeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  link: {
    type: String,
  },
  description: {
    type: String,
  },
});

const Anime = mongoose.model("Anime", AnimeSchema);

export default Anime;
