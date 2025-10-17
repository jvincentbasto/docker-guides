"use server";

import connectDb from "@/db/db";
import Task from "@/db/models/Task";

//
export const getTasks = async (payload = {}) => {
  const {} = payload;

  try {
    const isConnected = await connectDb();
    if (!isConnected) return [];

    const tasks = await Task.find({});
    return tasks;
  } catch (error) {
    console.log(error?.message);
    return [];
  }
};
export const createTask = async (payload = {}) => {
  const {} = payload;

  try {
    const isConnected = await connectDb();
    if (!isConnected) return;

    const newTask = await Task.create(payload);
    return newTask;
  } catch (error) {
    console.log(error?.message);
  }
};
