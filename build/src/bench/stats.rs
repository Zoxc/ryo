//! Sample statistics for `y bench` and `y bench crates`.

/// A cell is noisy when its standard deviation is more than this fraction of its median.
pub const NOISY: f64 = 0.03;

#[derive(Clone, Debug, PartialEq)]
pub struct Summary {
    pub n: usize,
    pub median: f64,
    pub min: f64,
    pub max: f64,
    pub mean: f64,
    /// Sample standard deviation (n - 1); 0 for one sample.
    pub stddev: f64,
}

impl Summary {
    /// `None` for no samples.
    pub fn of(samples: &[f64]) -> Option<Summary> {
        if samples.is_empty() {
            return None;
        }
        let mut sorted = samples.to_vec();
        sorted.sort_by(f64::total_cmp);
        let n = sorted.len();
        let median = if n % 2 == 1 { sorted[n / 2] } else { (sorted[n / 2 - 1] + sorted[n / 2]) / 2.0 };
        let mean = sorted.iter().sum::<f64>() / n as f64;
        let var = if n > 1 { sorted.iter().map(|x| (x - mean) * (x - mean)).sum::<f64>() / (n - 1) as f64 } else { 0.0 };
        Some(Summary { n, median, min: sorted[0], max: sorted[n - 1], mean, stddev: var.sqrt() })
    }

    pub fn noisy(&self) -> bool {
        self.median > 0.0 && self.stddev > NOISY * self.median
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn summary() {
        assert_eq!(Summary::of(&[]), None);
        let s = Summary::of(&[3.0, 1.0, 2.0]).unwrap();
        assert_eq!((s.n, s.median, s.min, s.max, s.mean, s.stddev), (3, 2.0, 1.0, 3.0, 2.0, 1.0));
        assert!(s.noisy());
        let s = Summary::of(&[4.0, 1.0, 2.0, 3.0]).unwrap();
        assert_eq!(s.median, 2.5);
        let s = Summary::of(&[5.0]).unwrap();
        assert_eq!((s.median, s.stddev), (5.0, 0.0));
        assert!(!s.noisy());
        // 1% spread is not noisy, 5% is.
        assert!(!Summary::of(&[1.0, 1.01, 0.99]).unwrap().noisy());
        assert!(Summary::of(&[1.0, 1.05, 0.95]).unwrap().noisy());
        assert!(!Summary::of(&[0.0, 0.0]).unwrap().noisy());
    }
}
