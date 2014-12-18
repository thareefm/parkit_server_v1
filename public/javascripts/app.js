L.mapbox.accessToken = 'pk.eyJ1IjoiamFtZXNsaXVtYXBzIiwiYSI6InhLTDh6eUEifQ.mpBGKMabJ51bqz0kktgoEA';

$(function() {
    var map = L.mapbox.map('map', 'jamesliumaps.kfd24anj', {
        zoomControl: false
    })
        .setView([-73.92,40.76], 17)
        .on('ready', function() {
            new L.Control.MiniMap(L.mapbox.tileLayer('jamesliumaps.7719d94c'))
                .addTo(map);
        });

    L.control.zoomslider().addTo(map);

    var runLayer = omnivore.kml('/mapbox.js/assets/data/line.kml')
        .on('ready', function() {
            map.fitBounds(runLayer.getBounds());

            // After the 'ready' event fires, the GeoJSON contents are accessible
            // and you can iterate through layers to bind custom popups.
            runLayer.eachLayer(function(layer) {
                // See the `.bindPopup` documentation for full details. This
                // dataset has a property called `name`: your dataset might not,
                // so inspect it and customize to taste.
                layer.bindPopup(layer.feature.properties.name);
            });
        })
        .addTo(map);
});