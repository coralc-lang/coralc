import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
const wastool = process.env.WASTOOL;
const casesDir = process.env.CASES;
const outDir = process.env.OUT;
const levels = process.env.LEVELS.split(/\s+/).filter(Boolean);
let pass = 0, fail = 0;
for (const file of fs.readdirSync(casesDir).filter(f => f.endsWith(".ir")).sort()) {
    const name = path.basename(file, ".ir");
    const src = fs.readFileSync(path.join(casesDir, file), "utf8");
    const m = src.match(/\/\/ *expect: *(-?\d+)/);
    const expect = m ? Number(m[1]) : 0;
    for (const lv of levels) {
        const base = path.join(outDir, `${name}_${lv}`);
        const r = spawnSync(wastool, [path.join(casesDir, file), base + ".wasm", lv], { encoding: "utf8" });
        if (r.status !== 0) {
            console.log(`FAIL assemble ${name} ${lv}: ${(r.stderr || (r.error && r.error.message) || "").trim()}`);
            fail++;
            continue;
        }
        const bytes = fs.readFileSync(base + ".wasm");
        if (!WebAssembly.validate(bytes)) {
            console.log(`FAIL validate ${name} ${lv}`);
            fail++;
            continue;
        }
        try {
            const mod = await import(`file://${base}.wasm.js?${Date.now()}_${Math.random()}`);
            const inst = await mod.instantiate(bytes);
            const got = inst.main();
            if (got !== expect) {
                console.log(`FAIL run ${name} ${lv}: got ${got}, want ${expect}`);
                fail++;
            } else pass++;
        } catch (e) {
            console.log(`FAIL node ${name} ${lv}: ${e.message}`);
            fail++;
        }
    }
}
console.log(`pass=${pass} fail=${fail}`);
process.exit(fail ? 1 : 0);
