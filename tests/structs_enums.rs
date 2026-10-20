//! Structs, enums with data, matching, Option/Result, Debug derives.
#[derive(Debug, Clone, Copy, PartialEq)]
struct Point {
    x: f64,
    y: f64,
}

#[derive(Debug)]
enum Shape {
    Circle { center: Point, r: f64 },
    Rect(Point, Point),
    Empty,
}

impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle { r, .. } => 3.0 * r * r,
            Shape::Rect(a, b) => ((b.x - a.x) * (b.y - a.y)).abs(),
            Shape::Empty => 0.0,
        }
    }
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
enum Small {
    A = 3,
    B = 7,
    C,
}

fn parse(s: &str) -> Result<i32, String> {
    s.parse::<i32>().map_err(|e| format!("{s:?}: {e}"))
}

fn main() {
    let shapes = [
        Shape::Circle { center: Point { x: 1.0, y: 2.0 }, r: 2.0 },
        Shape::Rect(Point { x: 0.0, y: 0.0 }, Point { x: 3.0, y: -4.0 }),
        Shape::Empty,
    ];
    for s in &shapes {
        println!("{s:?} area={}", s.area());
    }
    println!("{:?} {} {}", Small::C, Small::C as u8, Small::A < Small::B);
    println!("{:?} {:?}", parse("42"), parse("x1"));
    let nested: Option<Option<u8>> = Some(None);
    println!("{nested:?} {}", std::mem::size_of::<Option<Option<bool>>>());
    let t = (1u8, "two", 3.0f32, Point { x: -1.0, y: 0.5 });
    println!("{t:#?}");
}
