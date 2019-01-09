public virtual class MX_RT_TriggerHandler {

  // static map of handlername, times run() was invoked
  private static Map<String, LoopCount> loopCountMap;
  private static Set<String> bypassedHandlers;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private TriggerContext context;

  // teh current context event of the trigger, overridable in tests
  @TestVisible
  private TriggerEvent contextEvent;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

  // static initialization
  static 
  {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
  }
  
  // constructor
  public MX_RT_TriggerHandler() 
  {
    this.setTriggerContext();
  }

  /***************************************
   * public instance methods
   ***************************************/

  // main method that will be called during execution
  public void run() 
  {

    if(!validateRun())
    {
      return;
    }

    addToLoopCount();

    // dispatch to the correct handler method
    if(contextEvent == TriggerEvent.BEFORE)
    {
      runBeforeHandlers();
    } else if(contextEvent == TriggerEvent.AFTER)
    {
      runAfterHandlers();
    }
  }

  @TestVisible
  private void runBeforeHandlers(){
    if(this.context == TriggerContext.BEFORE_INSERT) 
    {
      this.beforeInsert();
    } else if(this.context == TriggerContext.BEFORE_UPDATE) 
    {
      this.beforeUpdate();
    } else if(this.context == TriggerContext.BEFORE_DELETE) 
    {
      this.beforeDelete();
    }
  }

  @TestVisible
  private void runAfterHandlers(){
    if(this.context == TriggerContext.AFTER_INSERT) 
    {
      this.afterInsert();
    } else if(this.context == TriggerContext.AFTER_UPDATE) 
    {
      this.afterUpdate();
    } else if(this.context == TriggerContext.AFTER_DELETE) 
    {
      this.afterDelete();
    } else if(this.context == TriggerContext.AFTER_UNDELETE) 
    {
      this.afterUndelete();
    }
  }

  public void setMaxLoopCount(Integer max) 
  {
    String handlerName = getHandlerName();
    if(MX_RT_TriggerHandler.loopCountMap.containsKey(handlerName)) 
    {
      MX_RT_TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    } else 
    {
      MX_RT_TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
    }
  }

  public void clearMaxLoopCount() 
  {
    this.setMaxLoopCount(-1);
  }

  /***************************************
   * public static methods
   ***************************************/

  public static void bypass(String handlerName) 
  {
    MX_RT_TriggerHandler.bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) 
  {
    MX_RT_TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) 
  {
    return MX_RT_TriggerHandler.bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() 
  {
    MX_RT_TriggerHandler.bypassedHandlers.clear();
  }

  /***************************************
   * private instancemethods
   ***************************************/

  @TestVisible
  private void setTriggerContext() 
  {
    this.setTriggerContext(null, false);
  }

  @TestVisible
  private void setTriggerContext(String forcedContext, Boolean testMode) 
  {
    if(Trigger.isExecuting || testMode)
    {
      this.isTriggerExecuting = true;
    } else
    {
      this.isTriggerExecuting = false;
      return;
    }
    
    if(forcedContext == null)
    {
      setStaticContext();
    }else
    {
      setForcedContext(forcedContext);
    }
  }

  @TestVisible
  private void setForcedContext(String forcedContext)
  {
    if(forcedContext.startsWith('before'))
    {
      setBeforeforcedContext(forcedContext);
    }else if(forcedContext.startsWith('after'))
    {
      setAfterforcedContext(forcedContext);
    }
  }

  @TestVisible
  private void setBeforeForcedContext(String forcedContext)
  {
    setBeforeContextEvent();
    if(forcedContext == 'before insert')
    {
      setBeforeInsertContext();
    }else if(forcedContext == 'before update')
    {
      setBeforeUpdateContext();
    }else if(forcedContext == 'before delete')
    {
      setBeforeDeleteContext();
    }
  }

  @TestVisible
  private void setAfterForcedContext(String forcedContext)
  {
    setAfterContextEvent();
    if(forcedContext == 'after insert')
    {
      setAfterInsertContext();
    }else if(forcedContext == 'after update')
    {
      setAfterUpdateContext();
    }else if(forcedContext == 'after delete')
    {
      setAfterDeleteContext();
    }else if(forcedContext == 'after undelete')
    {
      setAfterUndeleteContext();
    }
  }

  @TestVisible
  private void setStaticContext()
  {
    if(Trigger.isExecuting)
    {
      if(Trigger.isBefore)
      {
        setStaticBeforeContext();
      }else if(Trigger.isAfter)
      {
        setStaticAfterContext();
      }
    }
  }

  @TestVisible
  private void setStaticBeforeContext()
  {
    setBeforeContextEvent();
    if(Trigger.isInsert)
    {
      setBeforeInsertContext();
    }else if(Trigger.isUpdate)
    {
      setBeforeUpdateContext();
    }else if(Trigger.isDelete)
    {
      setBeforeDeleteContext();
    }
  }

  @TestVisible
  private void setStaticAfterContext()
  {
    setAfterContextEvent();
    if(Trigger.isInsert)
    {
      setAfterInsertContext();
    }else if(Trigger.isUpdate)
    {
      setAfterUpdateContext();
    }else if(Trigger.isDelete)
    {
      setAfterDeleteContext();
    }else if(Trigger.isUndelete)
    {
      setAfterUndeleteContext();
    }
  }

  @TestVisible
  private void setBeforeContextEvent(){
    this.contextEvent = TriggerEvent.BEFORE;
  }

  @TestVisible
  private void setAfterContextEvent(){
    this.contextEvent = TriggerEvent.AFTER;
  }

  @TestVisible
  private void setBeforeInsertContext()
  {
    this.context = TriggerContext.BEFORE_INSERT;
  }

  @TestVisible
  private void setBeforeUpdateContext()
  {
    this.context = TriggerContext.BEFORE_UPDATE;
  }

  @TestVisible
  private void setBeforeDeleteContext()
  {
    this.context = TriggerContext.BEFORE_DELETE;
  }

  @TestVisible
  private void setAfterInsertContext()
  {
    this.context = TriggerContext.AFTER_INSERT;
  }

  @TestVisible
  private void setAfterUpdateContext()
  {
    this.context = TriggerContext.AFTER_UPDATE;
  }

  @TestVisible
  private void setAfterDeleteContext()
  {
    this.context = TriggerContext.AFTER_DELETE;
  }

  @TestVisible
  private void setAfterUndeleteContext()
  {
    this.context = TriggerContext.AFTER_UNDELETE;
  }

  

  // increment the loop count
  @TestVisible
  private void addToLoopCount() 
  {
    String handlerName = getHandlerName();
    if(MX_RT_TriggerHandler.loopCountMap.containsKey(handlerName)) 
    {
      Boolean exceeded = MX_RT_TriggerHandler.loopCountMap.get(handlerName).increment();
      if(exceeded) 
      {
        Integer max = MX_RT_TriggerHandler.loopCountMap.get(handlerName).max;
        throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
      }
    }
  }

  // make sure this trigger should continue to run
  @TestVisible
  private Boolean validateRun() 
  {
    if(!this.isTriggerExecuting || this.context == null) 
    {
      throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }
    return !MX_RT_TriggerHandler.bypassedHandlers.contains(getHandlerName());
  }

  @TestVisible
  private String getHandlerName() 
  {
    return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
  }

  /***************************************
   * context methods
   ***************************************/

  // context-specific methods for override

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the before insert trigger event  
  **/
  @TestVisible
  protected virtual void beforeInsert(){}

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the before update trigger event 
  **/
  @TestVisible
  protected virtual void beforeUpdate(){}

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the before delete trigger event  
  **/
  @TestVisible
  protected virtual void beforeDelete(){}

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the after insert trigger event  
  **/
  @TestVisible
  protected virtual void afterInsert(){}

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the after update trigger event  
  **/
  @TestVisible
  protected virtual void afterUpdate(){}

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the after delete trigger event  
  **/
  @TestVisible
  protected virtual void afterDelete(){}

  /**
  * --------------------------------------------------------------------------------------
  * @Description Handles the after undelete trigger event  
  **/
  @TestVisible
  protected virtual void afterUndelete(){}

  /***************************************
   * inner classes
   ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
  private class LoopCount 
  {
    private Integer max;
    private Integer count;

    public LoopCount() 
    {
      this.max = 5;
      this.count = 0;
    }

    public LoopCount(Integer max) 
    {
      this.max = max;
      this.count = 0;
    }

    public Boolean increment() 
    {
      this.count++;
      return this.exceeded();
    }

    public Boolean exceeded() 
    {
      Boolean exceeded;
      if(this.max < 0)
      {
        exceeded = false;
      } else 
      {
        exceeded = (this.count > this.max);
      }
      return exceeded;
    }

    public Integer getMax() 
    {
      return this.max;
    }

    public Integer getCount() 
    {
      return this.count;
    }

    public void setMax(Integer max) 
    {
      this.max = max;
    }
  }

  // possible trigger contexts
  @TestVisible
  private enum TriggerContext 
  {
    BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
    AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
    AFTER_UNDELETE
  }

  @TestVisible
  private enum TriggerEvent
  {
    BEFORE, 
    AFTER
  }

  // exception class
  public class TriggerHandlerException extends Exception {}

}