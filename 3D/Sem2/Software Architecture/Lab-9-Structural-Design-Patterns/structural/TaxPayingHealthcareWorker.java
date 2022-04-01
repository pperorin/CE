package structural;

public class TaxPayingHealthcareWorker extends HealthcareWorkerDecorator{
    public TaxPayingHealthcareWorker(HealthcareWorker worker) {
        super(worker);
        System.out.println("Decorate " +  worker.getName() +" with TaxPaying.");
    }

    @Override
    public double getPrice() {
        return super.getPrice()*(1.1);
    }
}
