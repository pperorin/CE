package structural;

import java.util.LinkedHashSet;
import java.util.Set;

public class HealthcareWorkerTeam implements HealthcareServiceable{
    private Set<HealthcareServiceable> members = new LinkedHashSet<HealthcareServiceable>();
    public void addMember(HealthcareServiceable worker){
        members.add(worker);
    }
    public void removeMember(HealthcareServiceable worker){
        members.remove(worker);
    }
    public void service(){
        for(HealthcareServiceable m:members){
            m.service();
        }
    }
    public double getPrice(){
        double total_price=0;
        for(HealthcareServiceable m:members){
            total_price+= m.getPrice();
        }
        return total_price;
    }

}