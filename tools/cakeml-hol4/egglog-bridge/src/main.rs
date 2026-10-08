use std::env;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

fn arg_value(args: &[String], key: &str) -> Result<String, String> {
    args.windows(2)
        .find(|w| w[0] == key)
        .map(|w| w[1].clone())
        .ok_or_else(|| format!("missing {key}"))
}

fn quote_json(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    out.push('"');
    for c in s.chars() {
        match c {
            '\\' => out.push_str("\\\\"),
            '"' => out.push_str("\\\""),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if c.is_control() => out.push_str(&format!("\\u{:04x}", c as u32)),
            c => out.push(c),
        }
    }
    out.push('"');
    out
}

fn parse_rules(path: &Path) -> Result<Vec<(String, String, String)>, String> {
    let text = fs::read_to_string(path).map_err(|e| e.to_string())?;
    let mut rules = Vec::new();
    for (idx, raw) in text.lines().enumerate() {
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let fields: Vec<_> = raw.split('\t').collect();
        if fields.len() != 3 {
            return Err(format!(
                "{}:{}: expected name<TAB>lhs<TAB>rhs",
                path.display(),
                idx + 1
            ));
        }
        rules.push((
            fields[0].to_string(),
            fields[1].to_string(),
            fields[2].to_string(),
        ));
    }
    if rules.is_empty() {
        return Err("rewrite set is empty".into());
    }
    Ok(rules)
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    let run = || -> Result<(), String> {
        let egglog = arg_value(&args, "--egglog")?;
        let rules_path = PathBuf::from(arg_value(&args, "--rules")?);
        let lhs = arg_value(&args, "--lhs")?;
        let rhs = arg_value(&args, "--rhs")?;
        let out = PathBuf::from(arg_value(&args, "--out")?);
        let receipt = PathBuf::from(arg_value(&args, "--receipt")?);
        let rules = parse_rules(&rules_path)?;

        let mut program =
            String::from("(datatype Term (Var String) (Const String) (App Term Term))\n");
        for (_, l, r) in &rules {
            program.push_str("(rewrite ");
            program.push_str(l);
            program.push(' ');
            program.push_str(r);
            program.push_str(")\n");
        }
        program.push_str("(run 20)\n(check (= ");
        program.push_str(&lhs);
        program.push(' ');
        program.push_str(&rhs);
        program.push_str("))\n");

        let temp =
            env::temp_dir().join(format!("hol4-egglog-{}.egg", std::process::id()));
        fs::write(&temp, &program).map_err(|e| e.to_string())?;
        let status = Command::new(&egglog)
            .arg(&temp)
            .status()
            .map_err(|e| format!("cannot execute egglog: {e}"))?;
        let _ = fs::remove_file(&temp);

        let result = if status.success() { "candidate" } else { "rejected" };
        let mut receipt_file =
            fs::File::create(&receipt).map_err(|e| e.to_string())?;
        writeln!(
            receipt_file,
            "{{\n  \"schema\": 1,\n  \"status\": {},\n  \"egglog\": {},\n  \"rule_count\": {},\n  \"claim\": \"search hint only; HOL4 kernel replay required\"\n}}",
            quote_json(result),
            quote_json(&egglog),
            rules.len()
        )
        .map_err(|e| e.to_string())?;

        if !status.success() {
            return Err("egglog could not derive the candidate equality".into());
        }
        let names =
            rules.into_iter().map(|x| x.0).collect::<Vec<_>>().join("\n") + "\n";
        fs::write(out, names).map_err(|e| e.to_string())?;
        Ok(())
    };

    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("hol4-egglog-bridge: {e}");
            ExitCode::from(2)
        }
    }
}
