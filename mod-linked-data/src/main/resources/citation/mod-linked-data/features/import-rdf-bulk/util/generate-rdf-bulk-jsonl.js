function fn(args) {
  const templatePath = args && args.templatePath
    ? args.templatePath
    : 'classpath:citation/mod-linked-data/features/import-rdf-bulk/samples/rdf_template.json';
  const lineCount = args && args.lineCount ? args.lineCount : 250;
  const sourceFileName = args && args.sourceFileName
    ? args.sourceFileName
    : 'rdf-bulk-generated-' + java.lang.System.currentTimeMillis() + '.jsonl';
  const invalidLines = args && args.invalidLines ? args.invalidLines : [];

  const rdfTemplateText = karate.readAsString(templatePath);
  const generatedLines = [];

  for (let i = 1; i <= lineCount; i++) {
    const idValue = '' + (1000 + i);
    const replaced = rdfTemplateText.split('{ID_TO_BE_REPLACED}').join(idValue);
    const rdfLine = JSON.parse(replaced);
    generatedLines.push(JSON.stringify(rdfLine));
  }

  // Add caller-provided invalid lines at specific (1-based) line numbers.
  const sortedInvalidLines = invalidLines.slice().sort((a, b) => a.lineNumber - b.lineNumber);
  for (let i = 0; i < sortedInvalidLines.length; i++) {
    const item = sortedInvalidLines[i];
    const insertIndex = Math.max(0, Math.min(generatedLines.length, item.lineNumber - 1));
    generatedLines.splice(insertIndex, 0, item.json);
  }

  const bulkRdfJsonl = generatedLines.join('\n');
  const generatedFilePath = '' + karate.write(bulkRdfJsonl, sourceFileName);
  const generatedFilePathAbsolute = '' + new java.io.File(generatedFilePath).getAbsolutePath();

  return {
    sourceFileName: sourceFileName,
    generatedFilePathAbsolute: generatedFilePathAbsolute
  };
}
