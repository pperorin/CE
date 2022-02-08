const APIFeatures = require('../utils/apiFeatures');
const catchAsync = require('../utils/catchAsync');
const AppError = require('../utils/appError');

exports.testServer = (req, res) => {
    res.status(200).render('index', {
        title: 'Test Server'
    });
};