package com.solid.lsp;

// import com.solid.lsp.Shape;

public class Square implements Shape {
    private int side;

    Square(int side) {
        this.setSide(side);
    }

    public int getSide() {
        return side;
    }

    public void setSide(int side) {
        this.side = side;
    }

    public int getArea() {
        return side * side;
    }
}
