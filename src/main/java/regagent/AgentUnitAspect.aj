package regagent;


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
	@Pointcut("execution(* bpr.xtorm.img.reg.control.spn.PollingProcess.doWork(..))")
	public void init() {
	}
	@Around("AgentUnitAspect.init()")
	public Object init(ProceedingJoinPoint joinPoint) throws Throwable {
		
		String property = System.getProperty("MonLogId");
		if (property != null && property.length() > 0)
			logId = property;
		
		// monitoring init
		agent.init(null);
		System.out.println("Xmonitor aspect hass been initialized");
		agent.putEvent("[INFO]", "Server has been started", 1, System.currentTimeMillis(), "0", "", null);

		Object retVal = joinPoint.proceed();

		return retVal;
	}

	// term
	@Pointcut("execution(* bpr.xtorm.img.reg.mng.spnPoolManager.stopAll(..))")
	public void terminate() {
	}
	@Around("AgentUnitAspect.terminate()")
	public Object terminate(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = joinPoint.proceed();
		agent.shutdown();
		agent.putEvent("[INFO]", "Server has been shutdowned", 1, System.currentTimeMillis(), "0", "", null);
		return retVal;
	}

	// logging
	@Pointcut("execution(* bpr.xtorm.img.reg.lib.spnLogger.writeLog(..))")
	public void log4j() {}
	@Around("AgentUnitAspect.log4j()")
	public Object log4j(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = null;

		try {
			retVal = joinPoint.proceed();

			Object[] args = joinPoint.getArgs();
			String src = (String)args[0];
			String message = (String)args[1];
			String fileName = (String)args[2];

			StringBuffer sb = new StringBuffer();
			sb.append("[" + src + "]");
			sb.append("[" + fileName + "] ");
			sb.append(message);
			
			agent.putLog(logId, sb.toString(), System.currentTimeMillis(), "", "0", null);
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