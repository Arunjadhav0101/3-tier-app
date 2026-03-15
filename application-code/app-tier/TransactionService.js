const dbcreds = require('./DbConfig');
const mysql = require('mysql');

const con = mysql.createConnection({
    host: dbcreds.DB_HOST,
    user: dbcreds.DB_USER,
    password: dbcreds.DB_PWD,
    database: dbcreds.DB_DATABASE
});

function addTransaction(amount,desc){
    var sql = "INSERT INTO `transactions` (`amount`, `description`) VALUES (?,?)";
    con.query(sql, [amount, desc], function(err,result){
        if (err) throw err;
        console.log("Adding to the table should have worked");
    }) 
    return 200;
}

function getAllTransactions(callback){
    var mysql = "SELECT * FROM transactions";
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log("Getting all transactions...");
        return(callback(result));
    });
}

function findTransactionById(id,callback){
    var sql = "SELECT * FROM transactions WHERE id = ?";
    con.query(sql, [id], function(err,result){
        if (err) throw err;
        console.log(`retrieving transactions with id ${id}`);
        return(callback(result));
    }) 
}

function deleteAllTransactions(callback){
    var mysql = "DELETE FROM transactions";
    con.query(mysql, function(err,result){
        if (err) throw err;
        console.log("Deleting all transactions...");
        return(callback(result));
    }) 
}

function deleteTransactionById(id, callback){
    var sql = "DELETE FROM transactions WHERE id = ?";
    con.query(sql, [id], function(err,result){
        if (err) throw err;
        console.log(`Deleting transactions with id ${id}`);
        return(callback(result));
    }) 
}


module.exports = {addTransaction ,getAllTransactions, deleteAllTransactions, findTransactionById, deleteTransactionById};







