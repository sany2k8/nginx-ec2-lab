const express = require("express");
const app = express();

app.get("/", (req, res) => res.send("Hello from App 2 (port 4000)"));
app.get("/status", (req, res) => res.json({ app: "app2", status: "ok" }));

app.listen(4000, () => console.log("App2 running on 4000"));
