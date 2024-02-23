const express = require('express');
const path = require('path');
const app = express();

const Datastore = require('nedb');
const db = new Datastore('database.db');
db.loadDatabase();

//app.use('/ws-server', express.static(path.join(__dirname, '/ws-server')));

app.use(express.static(path.join(__dirname, '/public')));
app.use(express.json());

app.get('/info/:dynamic', (req, res) => {
    const { dynamic } = req.params;
    const { key } = req.query;
    const data = JSON.parse(key);
    if (dynamic == 'update') {
        console.log('turtle: ' + data.id);
        console.log(data.xPos, data.yPos, data.zPos, data.upD, data.fwdD, data.downD, data.advanced);
        db.update({ $and: [{ type: 1 }, { turtleID: data.id }] }, { type: 1, x: data.xPos, y: data.yPos, z: data.zPos, rotation: data.rotation, turtleID: data.id, advanced: data.advanced });
        if (data.up == 1) {
            console.log('up');
            console.log(data.xPos, data.yPos, data.zPos);
            db.insert({ type: 0, x: data.xPos, y: data.yPos + 1, z: data.zPos, blockID: data.upD });
        } else if (data.up == 2) {
            console.log('up delete');
            console.log(data.xPos, data.yPos, data.zPos);
            db.remove({ type: 0, x: data.xPos, y: data.yPos + 1, z: data.zPos });
        }
        if (data.fwd == 1) {
            console.log('forward');
            console.log(data.xPos, data.yPos, data.zPos);
            if (data.rotation == 0) {
                db.insert({ type: 0, x: data.xPos, y: data.yPos, z: data.zPos - 1, blockID: data.fwdD });
            } else if (data.rotation == 1) {
                db.insert({ type: 0, x: data.xPos + 1, y: data.yPos, z: data.zPos, blockID: data.fwdD });
            } else if (data.rotation == 2) {
                db.insert({ type: 0, x: data.xPos, y: data.yPos, z: data.zPos + 1, blockID: data.fwdD });
            } else if (data.rotation == 3) {
                db.insert({ type: 0, x: data.xPos - 1, y: data.yPos, z: data.zPos, blockID: data.fwdD });
            }
        } else if (data.fwd == 2) {
            console.log('forward delete');
            console.log(data.xPos, data.yPos, data.zPos);
            if (data.rotation == 0) {
                db.remove({ type: 0, x: data.xPos, y: data.yPos, z: data.zPos - 1 });
            } else if (data.rotation == 1) {
                db.remove({ type: 0, x: data.xPos + 1, y: data.yPos, z: data.zPos });
            } else if (data.rotation == 2) {
                db.remove({ type: 0, x: data.xPos, y: data.yPos, z: data.zPos + 1 });
            } else if (data.rotation == 3) {
                db.remove({ type: 0, x: data.xPos - 1, y: data.yPos, z: data.zPos });
            }
        }
        if (data.down == 1) {
            console.log('down');
            console.log(data.xPos, data.yPos, data.zPos);
            db.insert({ type: 0, x: data.xPos, y: data.yPos - 1, z: data.zPos, blockID: data.downD });
        } else if (data.down == 2) {
            console.log('down delete');
            console.log(data.xPos, data.yPos, data.zPos);
            db.remove({ type: 0, x: data.xPos, y: data.yPos - 1, z: data.zPos });
        }
        if (data.center) {
            console.log('center delete');
            console.log(data.xPos, data.yPos, data.zPos);
            db.remove({ type: 0, x: data.xPos, y: data.yPos, z: data.zPos });
        }
        db.loadDatabase();
        //db.insert({ type: 0, x: data.xPos, y: data.yPos, z: data.zPos, blockID: 'testBlock' });
        res.status(200).json({ info: 'update' });
    } else if (dynamic == 'world') {
        console.log('world');
        //console.log(data.xPos, data.yPos, data.zPos);
        db.find({ type: 0 }, function (err, docs) {
            //console.log(docs);
            //console.log(err);
            res.status(200).json({ info: docs });
        });
    } else if (dynamic == 'turtle') {
        console.log('turtle');
        //console.log(data.xPos, data.yPos, data.zPos);
        db.find({ type: 1 }, function (err, docs) {
            console.log(docs);
            //console.log(err);
            res.status(200).json({ info: docs });
        });
    } else if (dynamic == 'start') {
        console.log('start');
        db.findOne({ $and: [{ type: 1 }, { turtleID: data.id }] }, function (err, docs) {
            if (docs == undefined) {
                console.log('Turtle not in database');
                console.log('Id: ' + data.id + ' Advanced: ' + data.advanced);
                db.insert({ type: 1, x: data.x, y: data.y, z: data.z, rotation: data.rotation, turtleID: data.id, advanced: data.advanced }, function (err, newDoc) {
                    db.loadDatabase();
                    res.status(200).json({ info: newDoc });
                });
            } else {
                //console.log(docs);
                console.log('Turtle in database');
                res.status(200);
            }
            //console.log(err);
        });
    }
});

app.post('/', (req, res) => {
    const { parcel } = req.body;
    //console.log(parcel);
    if (!parcel) {
        return res.status(400).send({ status: 'failed' });
    }
    res.status(200).send({ status: 'recieved' });
    const data = parcel.json();
    //console.log(data.info);
});

app.use((req, res) => {
    res.status(404);
    res.send(`<h1>Error 404: Resource not found</h1>`);
});

app.listen(3000, () => {
    console.log("Turtle App listening on port 3000");
});

/*db.find({ $and: [{ x: e }, { y: a }, { z: d }] }, function (err, docs) {
    console.log(docs);
    console.log(err);
});*/
