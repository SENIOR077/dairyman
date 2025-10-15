const express = require("express");
const path = require("path");
const app = express();
const mysql = require("mysql");
const dbConn = mysql.createConnection({
  host: "localhost",
  database: "dairyman",
  user: "root",
  password: "Dennis7696",
  port: 3000,
});
const bcrypt = require("bcrypt");
const salt = bcrypt.genSaltSync(13);
const session = require("express-session");
const sqlQueries = require("./sqlStatement.js");
const utils = require("./utilis.js");

// middleware
app.use(express.static(path.join(__dirname, "public"))); // static files
app.use(express.urlencoded({ extended: true })); // parse form data
app.use(
  session({
    secret: "ojfsklfsmkfsmfsjfskjkfsjfkjkfjs",
    resave: false,
    saveUninitialized: true,
  })
);



// ✅ Setup EJS view engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// authorization middleware
const protectedRoutes = [
  "/dashboard",
  "/expenses",
  "/animal-profiles",
  "/milk-production",
  "/add-milk-production",
  "/add-expenses",
  "/vaccination",
];
app.use((req, res, next) => {
  if (protectedRoutes.includes(req.path)) {
    if (req.session && req.session.farmer) {
      res.locals.farmer = req.session.farmer;
      next();
    } else {
      res.redirect("/login?message=unauthorized");
    }
  } else {
    next();
  }
});

// root route
app.get("/", (req, res) => {
  res.render("index");
});

// Authentication routes
app.get("/register", (req, res) => {
  res.render("register");
});

app.get("/login", (req, res) => {
  const message = req.query.message;
  if (message === "exists") {
    res.locals.message = "Email already exists. Please login.";
  } else if (message === "success") {
    res.locals.message = "Registration successful. Please login.";
  } else if (message === "invalid") {
    res.locals.message = "Invalid email or password. Try again";
  } else if (message === "unauthorized") {
    res.locals.message = "You are unauthorized to access that page.";
  }
  res.render("login");
});

app.post("/register", (req, res) => {
  const { email, phone, password, fullname, farm_location, farm_name, county } =
    req.body;
  const hashedPassword = bcrypt.hashSync(password, salt);
  const insertFarmerStatement = `INSERT INTO farmers(fullname,phone,email,password,farm_name,farm_location,county) VALUES("${fullname}","${phone}","${email}","${hashedPassword}","${farm_name}","${farm_location}","${county}")`;
  const checkEmailStatement = `SELECT email FROM farmers WHERE email="${email}"`;

  dbConn.query(checkEmailStatement, (sqlErr, data) => {
    if (sqlErr) return res.status(500).send("Server Error");
    if (data.length > 0) {
      res.redirect("/login?message=exists");
    } else {
      dbConn.query(insertFarmerStatement, (insertError) => {
        if (insertError) {
          res.status(500).send("Error while registering farmer.");
        } else {
          res.redirect("/login?message=success");
        }
      });
    }
  });
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;
  const checkEmailStatement = `SELECT farmer_id,email,fullname,password FROM farmers WHERE email="${email}"`;
  dbConn.query(checkEmailStatement, (sqlErr, data) => {
    if (sqlErr) return res.status(500).send("Server Error " + sqlErr);
    if (data.length === 0) {
      res.redirect("/login?message=invalid");
    } else {
      const user = data[0];
      const passwordMatch = bcrypt.compareSync(password, user.password);
      if (passwordMatch) {
        req.session.farmer = user; // set session
        res.redirect("/dashboard");
      } else {
        res.redirect("/login?message=invalid");
      }
    }
  });
});

// Dashboard route
app.get("/dashboard", (req, res) => {
  dbConn.query(
    sqlQueries.getProductionRecordsForFarmer(req.session.farmer.farmer_id),
    (sqlErr, data) => {
      if (sqlErr) return res.status(500).send("Server Error!" + sqlErr);
      const groupedData = utils.groupAndExtractLatest(data);
      res.render("dashboard", { groupedData });
    }
  );
});

app.get("/animal-profiles", (req, res) => {
  dbConn.query(
    sqlQueries.getAnimalsProductionsForFarmer(req.session.farmer.farmer_id),
    (sqlErr, animals) => {
      if (sqlErr) return res.status(500).send("Server Error!" + sqlErr);
      dbConn.query(
        `select * from animal WHERE owner_id=${req.session.farmer.farmer_id}`,
        (err, allAnimalsForFarmer) => {
          res.render("animal-profiles", {
            animals: utils.getChartData(animals),
            allAnimalsForFarmer,
          });
        }
      );
    }
  );
});

app.post("/new-animal", (req, res) => {
  let { animal_tag, dob, purchase_date, breed, name, source, gender, status } =
    req.body;
  if (!purchase_date || purchase_date.length === 0) {
    purchase_date = "2000-01-01";
  }
  const insertAnimalStatement = `INSERT INTO animal(animal_tag,name,dob,purchase_date,breed,status,source,gender,owner_id) VALUES("${animal_tag}","${name}","${dob}","${purchase_date}","${breed}","${status}","${source}","${gender}", ${req.session.farmer.farmer_id})`;

  dbConn.query(insertAnimalStatement, (sqlErr) => {
    if (sqlErr) return res.status(500).send("Server Error!" + sqlErr);
    res.redirect("/animal-profiles");
  });
});

app.get("/milk-production", (req, res) => {
  const productionQuery = `
    SELECT 
        Animal.animal_tag,
        Animal.name as animal_name,
        MilkProduction.production_date,
        MilkProduction.production_time,
        quantity
    FROM MilkProduction 
    JOIN Animal ON MilkProduction.animal_id = Animal.animal_tag
    JOIN Farmers ON Animal.owner_id = Farmers.farmer_id
    WHERE Farmers.farmer_id = ${req.session.farmer.farmer_id}
    ORDER BY MilkProduction.production_date DESC
    LIMIT 30;`;

  dbConn.query(productionQuery, (sqlErr, productions) => {
    if (sqlErr) return res.status(500).send("Server Error!" + sqlErr);
    res.render("milk-production", { productions });
  });
});

app.get("/add-milk-production", (req, res) => {
  dbConn.query(
    `SELECT animal_tag,name FROM animal WHERE owner_id=${req.session.farmer.farmer_id} AND status = "Alive" AND gender = "Female"`,
    (sqlErr, animals) => {
      res.render("add-milk-production", { animals });
    }
  );
});

app.post("/milk-production", (req, res) => {
  let { animal_id, production_date, production_time, quantity } = req.body;
  if (!production_date || production_date.trim() === "") {
    production_date = new Date().toISOString().slice(0, 10);
  }

  const insertProductionQuery = `
    INSERT INTO MilkProduction (animal_id, production_date, production_time, quantity)
    VALUES (?, ?, ?, ?)
  `;

  dbConn.query(
    insertProductionQuery,
    [animal_id, production_date, production_time, quantity],
    (sqlErr) => {
      if (sqlErr) return res.status(500).send("Server Error! " + sqlErr);
      res.redirect("/milk-production");
    }
  );
});

app.post("/add-milk-production", (req, res) => {
  let { animal_id, production_date, production_time, quantity } = req.body;
  if (!production_date || production_date.length == 0) {
    production_date = new Date().toISOString().slice(0, 10);
  }
  const insertProductionStatement = `INSERT INTO MilkProduction(animal_id,production_date,production_time,quantity) VALUES("${animal_id}","${production_date}","${production_time}",${quantity})`;
  dbConn.query(insertProductionStatement, (sqlErr) => {
    if (sqlErr) return res.status(500).send("Server Error!" + sqlErr);
    res.redirect("/milk-production");
  });
});

// =======================
// EXPENSES ROUTES
// =======================

// Show expenses page
app.get("/expenses", (req, res) => {
  const farmerId = req.session.farmer.farmer_id; // assuming you store farmer in session

  const query = `
    SELECT expense_id, expense_date, expense_type, description, amount
    FROM expenses
    WHERE farmer_id = ?
    ORDER BY expense_date DESC
  `;

  dbConn.query(query, [farmerId], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).send("Database error");
    }

    // Calculate total and average
    let totalExpenses = 0;
    results.forEach((exp) => (totalExpenses += parseFloat(exp.amount)));

    const avgDailyExpenses =
      results.length > 0 ? totalExpenses / results.length : 0;

    res.render("expenses", {
      recentExpenses: results.slice(0, 7),
      totalExpenses,
      avgDailyExpenses,
      successMessage: req.session.successMessage || null,
    });

    // Clear message after showing it
    req.session.successMessage = null;
  });
});

// Handle new expense form submission
app.post("/add-expense", (req, res) => {
  const { expense_date, expense_type, description, amount } = req.body;
  const farmerId = req.session.farmer.farmer_id;

  const insertQuery = `
    INSERT INTO expenses (expense_date, expense_type, description, amount, farmer_id)
    VALUES (?, ?, ?, ?, ?)
  `;

  dbConn.query(
    insertQuery,
    [expense_date, expense_type, description, amount, farmerId],
    (err, result) => {
      if (err) {
        console.error(err);
        return res.status(500).send("Database error");
      }

      req.session.successMessage = "Expense recorded successfully!";
      res.redirect("/expenses");
    }
  );
});
// GET vaccination (Vaccination Management page)
// GET vaccination (Vaccination Management page)
app.get("/vaccination", (req, res) => {
  const farmerId = req.session.farmer.farmer_id;

  const animalQuery = `
    SELECT animal_tag, name 
    FROM Animal 
    WHERE owner_id = ? AND status="Alive"
  `;

  const recentVaccinationQuery = `
    SELECT 
      a.animal_tag,
      a.name AS animal_name,
      v.vaccine_name,
      v.date_administered,
      v.next_due_date,
      v.notes
    FROM Animal a
    JOIN Vaccination v 
      ON a.animal_tag = v.animal_id
    WHERE a.owner_id = ?
    ORDER BY v.date_administered DESC
    LIMIT 10
  `;

  const totalVaccinationsQuery = `SELECT COUNT(*) AS total FROM Vaccination`;
  const dueSoonQuery = `
    SELECT COUNT(*) AS dueSoon 
    FROM Vaccination
    WHERE next_due_date IS NOT NULL
    AND next_due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  `;

  dbConn.query(animalQuery, [farmerId], (err, animals) => {
    if (err) return res.status(500).send("DB error: " + err);

    dbConn.query(
      recentVaccinationQuery,
      [farmerId],
      (err, recentVaccinations) => {
        if (err) return res.status(500).send("DB error: " + err);

        dbConn.query(totalVaccinationsQuery, (err, totalResult) => {
          if (err) return res.status(500).send("DB error: " + err);

          dbConn.query(dueSoonQuery, (err, dueResult) => {
            if (err) return res.status(500).send("DB error: " + err);

            res.render("vaccination", {
              animals,
              recentVaccinations,
              totalVaccinations: totalResult[0].total,
              dueSoon: dueResult[0].dueSoon,
              successMessage:
                req.query.message === "success"
                  ? "Vaccination recorded successfully!"
                  : null,
            });
          });
        });
      }
    );
  });
});

// POST vaccination (adding new record)
app.post("/add-vaccination", (req, res) => {
  const { animal_id, vaccine_name, date_administered, next_due_date, notes } =
    req.body;

  const insertVaccinationQuery = `
    INSERT INTO Vaccination (animal_id, vaccine_name, date_administered, next_due_date, notes)
    VALUES (?, ?, ?, ?, ?)
  `;

  dbConn.query(
    insertVaccinationQuery,
    [animal_id, vaccine_name, date_administered, next_due_date, notes],
    (err) => {
      if (err) {
        console.error(err);
        return res.status(500).send("Server Error! " + err);
      }
      res.redirect("/vaccination?message=success");
    }
  );
});

// Logout route

app.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/login");
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
