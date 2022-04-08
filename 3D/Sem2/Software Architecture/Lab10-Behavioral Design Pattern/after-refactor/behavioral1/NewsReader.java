package edu.parinya.softarchdesign.behavioral;


public class NewsReader implements NewsSubscriber {
    // You need to implement this class
    private String name;

    public NewsReader(String string) {
        name = string;
    }

    @Override
    public void update(String content) {
        System.out.println(name+" => gets : "+content);
    }

    public String getName() {
        return name;
    }

}