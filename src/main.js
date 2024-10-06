const cluster = require('cluster');
const os = require('os');
const express = require('express');

if (cluster.isMaster) {
    
    const numCPUs = process.env.WORKERS || os.cpus().length;

    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }

    cluster.on('exit', (worker) => {
        console.log(`Worker ${worker.process.pid} died, starting a new one`);
        cluster.fork();
    });
} else {
    const app = express();

    app.get('/', (req, res) => {
        res.json({ message: 'Hello World' });
    });

    app.listen(8000, () => {
        console.log(`Worker ${process.pid} started`);
    });
}