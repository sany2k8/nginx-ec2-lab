const express = require("express");
const app = express();

app.get("/", (req, res) => res.send("Hello from Express behind Nginx"));
app.get("/users", (req, res) => res.json([{id:1,name:"Alice"},{id:2,name:"Bob"}]));

app.listen(3000, () => console.log("App1 running on 3000"));
