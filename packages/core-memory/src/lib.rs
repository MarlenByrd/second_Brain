use std::collections::{HashMap, HashSet};

#[derive(Debug, Clone)]
pub struct MemoryNode {
    pub id: String,
    pub importance: f32,
    pub recency: f32,
    pub emotional: f32,
    pub frequency: f32,
}

impl MemoryNode {
    pub fn score(&self) -> f32 {
        0.35 * self.importance + 0.25 * self.recency + 0.2 * self.emotional + 0.2 * self.frequency
    }
}

#[derive(Default)]
pub struct GraphEngine {
    pub edges: HashMap<String, Vec<(String, f32)>>,
}

impl GraphEngine {
    pub fn add_edge(&mut self, src: &str, dst: &str, weight: f32) {
        self.edges.entry(src.to_string()).or_default().push((dst.to_string(), weight));
    }

    pub fn spread_activation(&self, seed: &str, activation: f32, steps: usize) -> HashMap<String, f32> {
        let mut frontier = vec![(seed.to_string(), activation, 0usize)];
        let mut seen = HashSet::new();
        let mut out = HashMap::new();

        while let Some((node, energy, depth)) = frontier.pop() {
            if depth > steps || energy < 0.01 {
                continue;
            }
            let entry = out.entry(node.clone()).or_insert(0.0);
            *entry += energy;
            if !seen.insert((node.clone(), depth)) {
                continue;
            }
            if let Some(neighbors) = self.edges.get(&node) {
                for (next, w) in neighbors {
                    frontier.push((next.clone(), energy * w * 0.85, depth + 1));
                }
            }
        }
        out
    }
}
