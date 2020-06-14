---
title: "Rust初心者が陥りがちなコーディングとその対策"
date: 2020-06-07T03:22:26+0900
image: 
tags: 
  - 
---


# はじめに

Rust では Moveや借用、ライフといった概念が登場し、GAのある言語ではイディオムとして通用するコーディングスタイルのままコードを書くと、コンパイルさえ通らない、といったことが頻発します。

そこで、ここではRust初心者が陥りがちなコーディングスタイルとその対策について記します。

# コンストラクタ内で作ったインスタンスの参照を返す

```rust
struct Square<'a> {
    point: &'a Point,
    size: &'a Size
}

struct Size {
    width: i32,
    height: i32
}

struct Point {
    x: i32,
    y: i32
}

impl<'a> Square<'a> {
    fn new(x: i32, y:i32, width:i32, height: i32) -> Self {
        let size = &Size { width, height };
        let point = &Point { x, y };
        Square {
            point,
            size
        }
    }
}

fn main() {
    Square::new(10, 10, 10, 10);
}
```
上記のコードをコンパイルしようとすると以下のエラーが出ます。

```
$ cargo build                                                  (git)-[master]
   Compiling rust_anti_pattern v0.1.0 (/home/ymizushi/Develop/sandbox/rust/rust_anti_pattern)
error[E0515]: cannot return value referencing temporary value
  --> src/main.rs:20:9
   |
19 |           let point = &Point { x, y };
   |                        -------------- temporary value created here
20 | /         Square {
21 | |             point,
22 | |             size
23 | |         }
   | |_________^ returns a value referencing data owned by the current function

error[E0515]: cannot return value referencing temporary value
  --> src/main.rs:20:9
   |
18 |           let size = &Size { width, height };
   |                       ---------------------- temporary value created here
19 |           let point = &Point { x, y };
20 | /         Square {
21 | |             point,
22 | |             size
23 | |         }
   | |_________^ returns a value referencing data owned by the current function

error: aborting due to 2 previous errors

For more information about this error, try `rustc --explain E0515`.
error: could not compile `rust_anti_pattern`.

To learn more, run the command again with --verbose.
~
```

GCのある言語では上記のコードでも問題はないですが、Rustの場合は new 内でしか生存期間がない Size と Pointへの参照を返してしまっておりコンパイルが通りません.


# 解決策

できる場合は、所有権をnewの呼び出し元に返してあげるか、sizeと Pointへの参照をnewの引数に設定するかが必要です。

