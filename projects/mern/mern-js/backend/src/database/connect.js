import mongoose from "mongoose";

const connect = async () => {
  try {
    const dbUrl = process.env.DB_URL || process.env.LOCAL_DB_URL;
    if (!dbUrl) throw new Error("Missing Databse Connection String");

    await mongoose.connect(dbUrl);
    console.log("Successfully connected database");
  } catch (error) {
    console.log(`Failed to connect database - ${error.message}`);
    process.exit(1);
  }
};
export default connect;
