function (objToSearch, jsonpath, expected) {
    const reqs = karate.jsonPath(objToSearch, jsonpath);
    for (let i = 0; i < reqs.length; i++) {
        if (reqs[i] === expected) {
            return true;
        }
    }
    return false;
}
