const functions = require('firebase-functions');
const cors = require('cors')({origin: true});
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const firebaseAdmin = require('firebase-admin');
const uuid = require('uuid/v4')

const gcconfig = {
  projectId: 'flutter-easylist-11880',
  keyFilename: 'flutter-easylist.json'
};

const gcs = require('@google-cloud/storage')(gcconfig);

firebaseAdmin.initializeApp({ credential: firebaseAdmin.credential.cert(require('./flutter-easylist.json')) })

exports.storeImage = functions.https.onRequest((req, res) => {
  return cors(req, res, () => {
    if (req.method !== 'POST') {
      return res.status(500).json({ message: 'Not allowed' });
    }

    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    let idToken;
    idToken = req.headers.authorization.split(' ')[1];
    let uploadData;
    let oldImagePath;

    const busboy = new Busboy({ headers: req.headers });
    busboy.on('file', (fielname, file, filename, encoding, mimetype) => {
      const filePath = path.join(os.tmpdir(), filename);
      uploadData = { filePath, type: mimetype, name: filename };
      file.pipe(fs.WriteStream(filePath));
    });

    busboy.on('field', (fieldname, value) => {
      oldImagePath = decodeURIComponent(value);
    })

    busboy.on('finish', () => {
      const bucket = gcs.bucket('flutter-easylist-11880.appspot.com')
      const id = uuid();
      let imagePath = 'images/' + id + '-' + uploadData.name;
      if (oldImagePath) {
        imagePath = oldImagePath;
      }

      return firebaseAdmin.auth().verifyIdToken(idToken)
        .then(decodedToken => {
          return bucket.upload(uploadData.filePath, {
            uploadType: 'media',
            destination: imagePath,
            metadata: {
              metadata: {
                contentType: uploadData.type,
                firebaseStorageDownloadTokens: id
              }
            }
          })
        })
        .then(() => {
          return res.status(201).json({
            imageUrl: `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(imagePath)}?alt=media&token=${id}`,
            imagePath
          })
        })
        .catch(err => {
          return res.status(401).json({ error: 'Unauthorized' })
        });
    });

    return busboy.end(req.rawBody);
  });
});

exports.deleteImage = functions.database.ref('/products/{productId}')
  .onDelete(snapshot => {
    const imageData = snapshot.val();
    const imagePath = imageData.imagePath;

    const bucket = gcs.bucket('flutter-easylist-11880.appspot.com');
    return bucket.file(imagePath).delete();
  })

