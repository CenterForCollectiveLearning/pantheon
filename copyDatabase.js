conn = new Mongo();
db = conn.getDB('meteor');
db.dropDatabase();
db.copyDatabase('meteor_test', 'meteor');