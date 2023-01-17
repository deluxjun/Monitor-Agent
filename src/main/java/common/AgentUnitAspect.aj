package common;


import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

import com.speno.xmon.agent.MainXAgent;

@Aspect
public class AgentUnitAspect {
	
	private static MainXAgent agent = new MainXAgent();

	private String logId = "LOG1";
	
	// init
	@Pointcut("execution(* xmonitor.AgentUnit.startup(..))")
	public void init() {
	}
	@Around("AgentUnitAspect.init()")
	public Object init(ProceedingJoinPoint joinPoint) throws Throwable {
		
		Object retVal = joinPoint.proceed();
		
		String property = System.getProperty("MonLogId");
		if (property != null && property.length() > 0)
			logId = property;
		
		// monitoring init
		agent.init(null);
		System.out.println("Xmonitor aspect hass been initialized");
		agent.putEvent("[INFO]", "Server has been started", 1, System.currentTimeMillis(), "0", "", null);
		
		return retVal;
	}

	// term
	@Pointcut("execution(* xmonitor.AgentUnit.shutdown(..))")
	public void terminate() {
	}
	@Around("AgentUnitAspect.terminate()")
	public Object terminate(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = joinPoint.proceed();
		agent.putEvent("[INFO]", "Server has been shutdowned", 1, System.currentTimeMillis(), "0", "", null);
		return retVal;
	}

	// logging
	@Pointcut("execution(* xmonitor.AgentUnit.log(..))")
	public void log4j() {}
	@Around("AgentUnitAspect.log4j()")
	public Object log4j(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = null;

		try {
			retVal = joinPoint.proceed();

			Object[] args = joinPoint.getArgs();
			String message = (String)args[0];
			
			agent.putLog(logId, message, System.currentTimeMillis(), "", "0", null);
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			// TODO: put request
		}
		return retVal;
	}
	


}