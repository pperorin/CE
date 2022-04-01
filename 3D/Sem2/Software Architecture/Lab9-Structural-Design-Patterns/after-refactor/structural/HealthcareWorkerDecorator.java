package structural;

public abstract class HealthcareWorkerDecorator extends HealthcareWorker {

    protected HealthcareWorker worker;

    public HealthcareWorkerDecorator(HealthcareWorker worker) {
        super(worker);
        this.worker=worker;
    }

    @Override
    public void service() {
        worker.service();
    }

    @Override
    public double getPrice() {
        double price = worker.getPrice();
        return price;
    }
}
