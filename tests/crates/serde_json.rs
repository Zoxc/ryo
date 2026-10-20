//! `y bench crates` workload for serde_json: build a document, serialize, parse and walk it.
use serde_json::{Map, Value, json};

fn main() {
    let mut items = Vec::new();
    for i in 0..3000u64 {
        let mut tags = Map::new();
        tags.insert(format!("k{}", i % 17), json!(i * 3));
        items.push(json!({
            "id": i,
            "name": format!("item number {i}"),
            "price": i as f64 * 1.25 + 0.1,
            "active": i % 3 == 0,
            "tags": tags,
            "nested": [i, [i + 1, "x\ny\"z\u{e9}"], null],
        }));
    }
    let doc = Value::Array(items);
    let mut total = 0usize;
    for _ in 0..3 {
        let text = serde_json::to_string(&doc).unwrap();
        let pretty = serde_json::to_string_pretty(&doc).unwrap();
        let back: Value = serde_json::from_str(&text).unwrap();
        assert_eq!(back, doc);
        let back2: Value = serde_json::from_str(&pretty).unwrap();
        total += text.len() + pretty.len() + back2.as_array().unwrap().len();
    }
    let price: f64 = doc.as_array().unwrap().iter().map(|v| v["price"].as_f64().unwrap()).sum();
    println!("total {total}, price {price:.2}");
}
