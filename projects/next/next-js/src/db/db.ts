import mongoose from "mongoose";

const dbUrl = process.env.DB_URL || process.env.LOCAL_DB_URL;

const connectDb = async () => {
  try {
    await mongoose.connect(dbUrl);
    console.log("dbUrl", dbUrl);
    return true;
  } catch (error) {
    console.log(error?.message ?? "");
    return false;
  }
};

export default connectDb;
