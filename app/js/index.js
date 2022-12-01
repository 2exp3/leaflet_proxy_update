function ensureArray(x) {
  if (!(typeof (x) === 'object' && x.length)) {
    return [x];
  }
  return x;
}

window.LeafletWidget.methods.setFill = function setFill(category, layerId, style) {
  const map = this;
  if (!layerId) return;

  // Convert columnstore to row store.
  const convertedStyle = HTMLWidgets.dataframeToD3(style);

  ensureArray(layerId).forEach((d, i) => {
    const layer = map.layerManager.getLayer(category, d);
    if (layer) { // Or should this raise an error?
      layer.setStyle(convertedStyle[i]);
    }
  });
};
