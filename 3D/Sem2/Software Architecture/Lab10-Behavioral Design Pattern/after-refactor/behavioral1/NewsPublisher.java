package edu.parinya.softarchdesign.behavioral;

import java.util.ArrayList;

public class NewsPublisher {

    private ArrayList<NewsSubscriber> subscribers = new ArrayList<NewsSubscriber>();
    private News mainState;
    private String name;

    public NewsPublisher(){
    }


    public void subscribe(NewsSubscriber subscriber) {
        subscribers.add(subscriber);
    }

    public void unsubscribe(NewsSubscriber subscriber) {
        subscribers.remove(subscriber);
    }

    public void notifySubscriber(String content) {
        System.out.println("*** Publisher: "+name+" is sending "+mainState.getTopic()+" news to subscribers ***");
        for (NewsSubscriber s : subscribers) {
            s.update(content);
        }
        System.out.println("!!! sending done.!!! \n");

    }

    public void publish(News newState){
        mainState = newState;
        notifySubscriber(mainState.getContent());
    }

    public String getName() {
        return name;
    }
}