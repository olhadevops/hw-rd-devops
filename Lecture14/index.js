const { MongoClient } = require("mongodb");
const fs = require("fs");

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);

async function run() {
    await client.connect();
    const db = client.db("gymDatabase");

    const clients = db.collection("clients");
    const memberships = db.collection("memberships");
    const workouts = db.collection("workouts");
    const trainers = db.collection("trainers");

    await clients.deleteMany({});
    await memberships.deleteMany({});
    await workouts.deleteMany({});
    await trainers.deleteMany({});

    await clients.insertMany([
        { client_id: 1, name: "Anna Ivanova", age: 28, email: "anna@example.com" },
        { client_id: 2, name: "Ivan Petrov", age: 35, email: "ivan@example.com" },
        { client_id: 3, name: "Oleh Bondarenko", age: 42, email: "oleh@example.com" }
    ]);

    await memberships.insertMany([
        { membership_id: 101, client_id: 1, start_date: "2025-01-01", end_date: "2025-12-31", type: "Annual" },
        { membership_id: 102, client_id: 2, start_date: "2025-03-01", end_date: "2025-09-01", type: "Semi-Annual" }
    ]);

    await workouts.insertMany([
        { workout_id: 201, description: "Cardio session", difficulty: "medium" },
        { workout_id: 202, description: "Strength training", difficulty: "hard" },
        { workout_id: 203, description: "Stretching", difficulty: "easy" }
    ]);

    await trainers.insertMany([
        { trainer_id: 301, name: "Olga Shevchenko", specialization: "Yoga" },
        { trainer_id: 302, name: "Dmytro Kravets", specialization: "Weightlifting" }
    ]);

    const over30 = await clients.find({ age: { $gt: 30 } }).toArray();
    const mediumWorkouts = await workouts.find({ difficulty: "medium" }).toArray();
    const membershipInfo = await memberships.find({ client_id: 2 }).toArray();

    let report = "";

    report += "Клієнти старше 30:\n";
    report += JSON.stringify(over30, null, 2) + "\n\n";

    report += "Тренування середньої складності:\n";
    report += JSON.stringify(mediumWorkouts, null, 2) + "\n\n";

    report += "Членство клієнта client_id=2:\n";
    report += JSON.stringify(membershipInfo, null, 2) + "\n\n";

    fs.writeFileSync("report.txt", report);

    await client.close();
}

run();
