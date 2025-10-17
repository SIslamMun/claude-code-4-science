# Warpio ↔ DSPy Architecture Mapping Guide

**Version:** 1.0
**Purpose:** Detailed mapping between current Warpio architecture and DSPy implementation
**Audience:** Developers implementing DSPy-enhanced Warpio

---

## Visual Architecture Comparison

### Current Warpio Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      WARPIO.md (v0.1.0)                         │
│                  Identity & Orchestration                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Priority Decision Matrix (Lines 23-64)                         │
│  ├─ Rule 1: MCP Requirements → Expert Routing                   │
│  ├─ Rule 2: Single vs Multi-Domain Detection                    │
│  ├─ Rule 3: Context Analysis (Simple Q vs Task)                 │
│  └─ Rule 4: Sensitivity Check                                   │
│                                                                  │
│  Exclusive MCP Assignments (Lines 100-133)                      │
│  ├─ data-expert: hdf5, adios, parquet, compression             │
│  ├─ hpc-expert: slurm, darshan, node_hardware, lmod            │
│  ├─ analysis-expert: plot, pandas (viz focus)                  │
│  ├─ research-expert: arxiv, context7                            │
│  └─ workflow-expert: jarvis, filesystem                         │
│                                                                  │
│  Orchestration Patterns (Lines 136-184)                         │
│  ├─ Single: Direct delegation                                   │
│  ├─ Parallel: concurrent Task tool calls                        │
│  ├─ Sequential: chained execution                               │
│  └─ Iterative: feedback loops                                   │
│                                                                  │
│  Execution via Task Tool                                        │
│  └─ subagent_type: data-expert, hpc-expert, etc.              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  data-expert.md │  │  hpc-expert.md  │  │ analysis-...md  │
│                 │  │                 │  │                 │
│  Lines 1-20:    │  │  Lines 1-20:    │  │  Lines 1-20:    │
│  Frontmatter    │  │  Frontmatter    │  │  Frontmatter    │
│                 │  │                 │  │                 │
│  Lines 23-65:   │  │  Lines 23-65:   │  │  Lines 23-65:   │
│  Core Expertise │  │  Core Expertise │  │  Core Expertise │
│                 │  │                 │  │                 │
│  Lines 68-110:  │  │  Lines 68-110:  │  │  Lines 68-110:  │
│  Response Proto │  │  Response Proto │  │  Response Proto │
│                 │  │                 │  │                 │
│  Invoked via    │  │  Invoked via    │  │  Invoked via    │
│  Task tool      │  │  Task tool      │  │  Task tool      │
│                 │  │                 │  │                 │
│  MCP tools used │  │  MCP tools used │  │  MCP tools used │
│  manually in    │  │  manually in    │  │  manually in    │
│  expanded prompt│  │  expanded prompt│  │  expanded prompt│
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### DSPy-Enhanced Warpio Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│            WarpioOrchestrator (dspy.Module)                     │
│                  Learned Routing & Orchestration                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  dspy.ChainOfThought(OrchestratorSignature)                    │
│  ├─ Input: task, history, available_experts                     │
│  ├─ Output: reasoning, expert_selection, strategy               │
│  └─ Optimized via MIPROv2 (learns patterns from logs)          │
│                                                                  │
│  Expert Registry (self.experts dict)                            │
│  ├─ "data": DataExpert() instance                               │
│  ├─ "hpc": HPCExpert() instance                                 │
│  ├─ "analysis": AnalysisExpert() instance                       │
│  └─ "research": ResearchExpert() instance                       │
│                                                                  │
│  Execution Strategies (learned, not hardcoded)                  │
│  ├─ Single: self.experts[name](task)                           │
│  ├─ Parallel: asyncio.gather([expert.acall()...])             │
│  ├─ Sequential: for expert in chain: expert(task)              │
│  └─ Iterative: while not done: expert(feedback)                │
│                                                                  │
│  Cost Tracking & Observability                                  │
│  ├─ MLflow tracing (OpenTelemetry)                             │
│  ├─ Token usage tracking                                        │
│  └─ Performance metrics                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────────────────────────────────────────────────────┐
│           DataExpert (dspy.Module)                            │
│  dspy.ReAct(DataExpertSignature, tools=[...])               │
│                                                               │
│  Signature (declarative):                                    │
│  ├─ Inputs: task, file_context                               │
│  └─ Outputs: analysis, recommendations, mcp_commands         │
│                                                               │
│  Tools (MCP wrappers):                                       │
│  ├─ hdf5_analyze(filepath) → call_mcp("hdf5", "analyze")    │
│  ├─ hdf5_optimize(filepath) → call_mcp("hdf5", "optimize")  │
│  ├─ adios_convert(path) → call_mcp("adios", "convert")      │
│  └─ parquet_read(path) → call_mcp("parquet", "read")        │
│                                                               │
│  ReAct Loop (automatic):                                     │
│  1. Think: What should I do?                                 │
│  2. Act: Call tool (e.g., hdf5_analyze)                     │
│  3. Observe: Tool result                                     │
│  4. Repeat until done                                        │
│                                                               │
│  Optimized Prompt (auto-generated):                          │
│  ├─ Instruction: [Generated by MIPROv2]                      │
│  ├─ Demos: [4-8 high-quality traces from logs]              │
│  └─ Context: [Dynamically selected examples]                │
│                                                               │
│  Execution Model:                                             │
│  ├─ LM: Llama-3.1-8B (local) or GPT-4o-mini                 │
│  ├─ Caching: 3-layer (memory/disk/provider)                 │
│  └─ Async: Concurrent tool calls                             │
└──────────────────────────────────────────────────────────────┘
```

---

## Component-by-Component Mapping

### 1. Orchestration Layer

| Current Warpio | DSPy Equivalent | Key Differences |
|----------------|-----------------|-----------------|
| **WARPIO.md (identity)** | `WarpioOrchestrator(dspy.Module)` | Compilable, learned routing |
| **Priority Decision Matrix** | `dspy.ChainOfThought(OrchestratorSignature)` | Optimized from usage logs |
| **Manual routing rules** | Learned routing patterns | 30%+ better routing accuracy |
| **Task tool calls** | Direct method invocation | Type-safe, faster |
| **Static orchestration** | Dynamic strategy selection | Adapts to task complexity |

**Code Mapping:**

```python
# Current Warpio (WARPIO.md, lines 23-64)
"""
1. MCP Requirements Check
   - If task mentions HDF5/ADIOS → data-expert
   - If task mentions SLURM → hpc-expert
   - ...

2. Single vs Multi-Domain
   - Pattern matching on keywords
   - Hardcoded decision tree
"""

# DSPy Equivalent
class OrchestratorSignature(dspy.Signature):
    """Route tasks to experts based on requirements."""
    task: str = dspy.InputField()
    available_experts: dict = dspy.InputField()

    reasoning: str = dspy.OutputField()
    expert_selection: str = dspy.OutputField()
    strategy: str = dspy.OutputField()  # single/parallel/sequential

class WarpioOrchestrator(dspy.Module):
    def __init__(self):
        super().__init__()
        # Learned routing (not hardcoded rules)
        self.router = dspy.ChainOfThought(OrchestratorSignature)

    def forward(self, task):
        routing = self.router(task=task, available_experts=self.get_experts())
        # Optimized from usage logs, learns patterns automatically
        return self.execute_strategy(routing)
```

### 2. Expert Definitions

| Current Warpio | DSPy Equivalent | Key Differences |
|----------------|-----------------|-----------------|
| **Expert markdown files** | `dspy.Signature` + `dspy.Module` | Compilable, optimizable |
| **Frontmatter (name, tools)** | Class attributes + tool list | Type-safe definitions |
| **Core Expertise section** | Signature docstring | Used by optimizer |
| **Response Protocol** | Module `forward()` method | Executable logic |
| **Manual prompt text** | Auto-generated instructions | 20-100% better prompts |

**Code Mapping:**

```python
# Current: warpio/agents/data-expert.md
"""
---
name: data-expert
description: Scientific data I/O and optimization specialist
tools: Bash, Read, Write, mcp__hdf5__*, mcp__adios__*, mcp__parquet__*
---

# Data Expert - Scientific Data I/O Specialist

## Core Expertise
- HDF5 file optimization (compression, chunking)
- ADIOS format conversion and performance tuning
- Parquet analytics integration
- Performance benchmarking with Darshan

## Response Protocol
1. Use TodoWrite to plan analysis steps
2. Actually invoke MCP tools (hdf5, adios, parquet)
3. Provide specific optimization recommendations
4. Include performance metrics and benchmarks
"""

# DSPy Equivalent: warpio/dspy_experts/data_expert.py
class DataExpertSignature(dspy.Signature):
    """Scientific data I/O and optimization specialist.

    Core expertise: HDF5 optimization (compression, chunking),
    ADIOS conversion, Parquet integration, performance benchmarking.
    """

    # Inputs
    task: str = dspy.InputField(desc="User's data I/O task")
    file_context: dict = dspy.InputField(desc="File metadata")

    # Outputs
    analysis: str = dspy.OutputField(desc="Technical analysis")
    recommendations: list[str] = dspy.OutputField(desc="Optimization steps")
    mcp_commands: list[dict] = dspy.OutputField(desc="MCP tool calls")

class DataExpert(dspy.Module):
    def __init__(self):
        super().__init__()
        self.agent = dspy.ReAct(
            signature=DataExpertSignature,
            tools=[hdf5_analyze, hdf5_optimize, adios_convert, parquet_read],
            max_iters=5
        )

    def forward(self, task, file_context):
        # ReAct automatically:
        # 1. Plans steps (replaces TodoWrite)
        # 2. Invokes MCP tools
        # 3. Provides recommendations
        # 4. Tracks performance
        return self.agent(task=task, file_context=file_context)
```

### 3. MCP Tool Integration

| Current Warpio | DSPy Equivalent | Key Differences |
|----------------|-----------------|-----------------|
| **MCP tools mentioned in prompts** | Python function wrappers | Directly callable |
| **Manual tool invocation** | Automatic tool selection | ReAct decides when/how |
| **No retry logic** | Built-in error handling | Exponential backoff |
| **No validation** | Tool output validation | Type checking |

**Code Mapping:**

```python
# Current: Tools mentioned in expert prompts
"""
Use mcp__hdf5__analyze to analyze file structure
Use mcp__hdf5__optimize to apply optimizations
"""

# DSPy: Python function wrappers
def hdf5_analyze(filepath: str) -> dict:
    """Analyze HDF5 file structure.

    Args:
        filepath: Absolute path to HDF5 file

    Returns:
        Dict with compression, chunking, dataset info
    """
    from mcp_client import call_mcp

    try:
        result = call_mcp("hdf5", "analyze", {"filepath": filepath})
        return result
    except Exception as e:
        # Fallback or retry
        return {"error": str(e), "fallback": basic_analyze(filepath)}

# ReAct uses tools automatically
agent = dspy.ReAct(
    signature="task -> analysis",
    tools=[hdf5_analyze, hdf5_optimize, adios_convert],
    max_iters=5
)

# Tool selection is learned during optimization
result = agent(task="Optimize my climate simulation HDF5 file")
# ReAct automatically:
# 1. Calls hdf5_analyze(filepath)
# 2. Observes results
# 3. Decides next tool (hdf5_optimize)
# 4. Returns recommendations
```

### 4. Execution Flow

| Current Warpio | DSPy Equivalent | Key Differences |
|----------------|-----------------|-----------------|
| **Task tool delegation** | Direct module invocation | No subprocess overhead |
| **Prompt expansion** | Signature compilation | Pre-optimized |
| **No state management** | Built-in state tracking | Conversation history |
| **No cost tracking** | Automatic token tracking | Budget management |
| **No observability** | MLflow tracing | Full execution visibility |

**Flow Diagram Comparison:**

```
Current Warpio Flow:
User → Claude Code → WARPIO.md → Task tool → Expert .md → Prompt expansion → LM call → MCP tool mention

DSPy Flow:
User → WarpioOrchestrator.forward() → Expert.forward() → ReAct loop → MCP tool call → Result
       ↓                                    ↓                   ↓              ↓           ↓
    Cached routing                    Cached expert        Tool cache    MCP cache   Cached result
```

### 5. Optimization and Learning

| Current Warpio | DSPy Equivalent | Key Differences |
|----------------|-----------------|-----------------|
| **No learning** | Automatic optimization | Continuous improvement |
| **Manual prompt tuning** | Learned prompts | 20-100% better |
| **Static expertise** | Dynamic adaptation | Learns from usage |
| **No A/B testing** | Built-in evaluation | Data-driven |
| **No metrics** | Comprehensive metrics | Performance tracking |

**Optimization Workflow:**

```python
# Current: Manual prompt improvement
"""
1. User reports issue
2. Developer reads logs
3. Developer modifies expert .md file
4. Commit and deploy
5. Hope it's better
"""

# DSPy: Automatic optimization
def optimize_weekly():
    """Automatic weekly optimization from logs."""

    # 1. Collect usage logs
    logs = load_logs(last_7_days=True)
    trainset = convert_to_examples(logs)

    # 2. Define quality metric
    def quality(example, pred, trace=None):
        return (
            task_completed(example, pred) +
            tool_efficiency(pred.trajectory) +
            user_satisfaction(pred)
        ) / 3.0

    # 3. Optimize
    optimizer = dspy.MIPROv2(metric=quality, auto='medium')
    compiled = optimizer.compile(expert, trainset=trainset)

    # 4. A/B test
    if evaluate(compiled) > evaluate(current_expert):
        deploy(compiled)
        notify_team(f"Expert improved by {improvement}%")
```

---

## Feature Mapping Matrix

| Feature | Current Warpio | DSPy-Enhanced | Improvement |
|---------|----------------|---------------|-------------|
| **Routing Accuracy** | Rule-based | Learned | +30-50% |
| **Expert Quality** | Manual prompts | Optimized prompts | +20-100% |
| **Tool Selection** | Mentioned in prompts | Automatic ReAct | +40% efficiency |
| **Error Handling** | Basic | Built-in retry | 90% fewer failures |
| **Cost** | Unpredictable | Tracked & optimized | -30-50% |
| **Latency** | Variable | 3-layer caching | -60% |
| **Observability** | Logs only | MLflow tracing | Full visibility |
| **Learning** | None | Continuous | Always improving |
| **A/B Testing** | Manual | Built-in | Data-driven |
| **Local AI** | Zen MCP only | First-class | Privacy + cost |

---

## Migration Strategy

### Phase 1: Single Expert Proof of Concept

**Goal:** Validate DSPy works for Warpio

**Scope:** `data-expert.md` → `DataExpert(dspy.Module)`

**Steps:**

1. **Keep existing system running**
   - No changes to WARPIO.md
   - No changes to other experts
   - Add feature flag: `WARPIO_USE_DSPY_DATA_EXPERT=false`

2. **Implement DataExpert in DSPy**
   ```python
   # warpio/dspy_experts/data_expert.py
   class DataExpert(dspy.Module):
       # ... (see code examples above)
   ```

3. **Wrap MCP tools**
   ```python
   # warpio/dspy_experts/mcp_tools.py
   def hdf5_analyze(filepath: str) -> dict:
       return call_mcp("hdf5", "analyze", {"filepath": filepath})
   ```

4. **Collect 10 test examples**
   ```python
   # tests/data/data_expert_examples.py
   examples = [
       dspy.Example(
           task="Optimize my 50GB HDF5 simulation file",
           file_context={"path": "/data/sim.h5", "size": "50GB"},
           expected_analysis="...",
           expected_recommendations=["Apply GZIP-6", "Rechunk to 100x100x100"]
       ).with_inputs("task", "file_context")
   ]
   ```

5. **Run BootstrapFewShot**
   ```bash
   python -m warpio.dspy_experts.optimize data-expert
   # Cost: $2-5, Time: 10-30 min
   ```

6. **Compare performance**
   ```python
   baseline_score = evaluate(ManualDataExpert(), test_set)
   dspy_score = evaluate(OptimizedDataExpert(), test_set)
   improvement = (dspy_score - baseline_score) / baseline_score
   print(f"Improvement: +{improvement*100:.1f}%")
   ```

**Success Criteria:**
- ✅ DSPy expert completes all 10 test tasks
- ✅ MCP tools called correctly (verified in trajectory)
- ✅ 15%+ improvement over baseline
- ✅ No regressions on existing functionality

**Time:** 1-2 days
**Risk:** Very low (isolated change)

### Phase 2: Multi-Expert System

**Goal:** Convert all 5 experts to DSPy

**Scope:** All experts + orchestrator

**Timeline:**

**Weeks 1-2: Expert Conversion**
- Convert `hpc-expert.md` → `HPCExpert(dspy.Module)`
- Convert `analysis-expert.md` → `AnalysisExpert(dspy.Module)`
- Convert `research-expert.md` → `ResearchExpert(dspy.Module)`
- Convert `workflow-expert.md` → `WorkflowExpert(dspy.Module)`

**Weeks 3-4: Orchestrator**
- Implement `WarpioOrchestrator(dspy.Module)`
- Migrate routing logic from WARPIO.md
- Add feature flag: `WARPIO_USE_DSPY_ORCHESTRATOR=false`

**Weeks 5-6: Integration Testing**
- Test single expert routing
- Test parallel expert orchestration
- Test sequential workflows
- Test iterative refinement

**Weeks 7-8: Controlled Rollout**
- 10% of users get DSPy orchestrator
- Collect comparative metrics
- Fix any issues discovered
- Increase to 50% if successful
- 100% rollout by end of week 8

**Success Criteria:**
- ✅ All 5 experts passing test suites
- ✅ Orchestrator routes correctly (>90% accuracy)
- ✅ No regressions in user experience
- ✅ Performance improvement measurable

**Time:** 8 weeks
**Risk:** Medium (larger scope)

### Phase 3: Optimization & Production

**Goal:** Optimize experts from real usage logs

**Timeline:**

**Week 9: Data Collection**
- Enable comprehensive logging
- Collect 200+ real usage examples
- Label examples with quality scores
- Create train/validation split (20/80)

**Week 10: Optimization**
- Run MIPROv2 for each expert (40+ trials)
- Cost: $10-30 per expert ($50-150 total)
- Time: 1-2 hours per expert
- Validate improvements on holdout set

**Week 11: Deployment**
- Deploy optimized experts
- A/B test (50% users optimized, 50% baseline)
- Monitor performance metrics
- Collect feedback

**Week 12: Finalization**
- Full rollout of optimized experts
- Remove old system code
- Documentation updates
- Set up automatic weekly re-optimization

**Success Criteria:**
- ✅ 30%+ improvement in expert quality
- ✅ Positive user feedback
- ✅ Cost reduction measurable
- ✅ Automatic optimization pipeline working

**Time:** 4 weeks
**Risk:** Low (gradual rollout)

---

## Backward Compatibility

### Fallback Strategy

```python
# warpio/expert_router.py

class ExpertRouter:
    """Routes tasks to experts with DSPy/manual fallback."""

    def __init__(self):
        self.use_dspy = os.getenv("WARPIO_USE_DSPY", "false") == "true"

        if self.use_dspy:
            try:
                self.orchestrator = WarpioOrchestrator()
                self.orchestrator.load("compiled/orchestrator_v1.json")
            except Exception as e:
                logger.warning(f"Failed to load DSPy orchestrator: {e}")
                self.use_dspy = False
                self.orchestrator = None

    def route(self, task: str):
        """Route task to appropriate expert."""

        if self.use_dspy and self.orchestrator:
            try:
                return self.orchestrator(task=task)
            except Exception as e:
                logger.error(f"DSPy routing failed: {e}, falling back")
                # Fallback to manual routing
                return self.manual_route(task)
        else:
            return self.manual_route(task)

    def manual_route(self, task: str):
        """Original rule-based routing (from WARPIO.md)."""
        # ... existing logic ...
```

### Feature Flags

```bash
# .env or environment variables

# Master switch
WARPIO_USE_DSPY=true

# Per-expert switches
WARPIO_DSPY_DATA_EXPERT=true
WARPIO_DSPY_HPC_EXPERT=true
WARPIO_DSPY_ANALYSIS_EXPERT=false  # Rollback if issues

# Orchestrator
WARPIO_DSPY_ORCHESTRATOR=true

# Optimization
WARPIO_DSPY_AUTO_OPTIMIZE=true
WARPIO_DSPY_OPTIMIZE_SCHEDULE="0 2 * * 0"  # Weekly at 2am Sunday

# A/B testing
WARPIO_DSPY_ROLLOUT_PERCENTAGE=50  # 50% of users
```

### Rollback Procedure

```bash
# Instant rollback to manual system
export WARPIO_USE_DSPY=false

# Or selective rollback
export WARPIO_DSPY_DATA_EXPERT=false  # Just data expert
export WARPIO_DSPY_ORCHESTRATOR=false  # Just orchestrator

# Restart Claude Code (or reload config)
pkill -HUP claude
```

---

## Performance Benchmarks

### Expected Improvements

Based on DSPy research and Warpio's current architecture:

| Metric | Baseline | DSPy-Enhanced | Improvement |
|--------|----------|---------------|-------------|
| **Routing Accuracy** | 70% | 90%+ | +28% |
| **Task Completion** | 60% | 85%+ | +42% |
| **Tool Selection** | 65% | 90%+ | +38% |
| **Response Quality** | 55% | 80%+ | +45% |
| **Cost per Task** | Variable | 30-50% lower | -40% avg |
| **Latency (cached)** | 3-5s | 0.5-1s | -70% |
| **User Satisfaction** | Baseline | Expected +30-50% | TBD |

### Measurement Strategy

```python
# warpio/metrics.py

class WarpioMetrics:
    """Track Warpio performance metrics."""

    def measure_routing_accuracy(self, test_set):
        """Measure if orchestrator routes to correct expert."""
        correct = 0
        for example in test_set:
            pred_expert = self.orchestrator(example.task).expert_used
            if pred_expert == example.correct_expert:
                correct += 1
        return correct / len(test_set)

    def measure_task_completion(self, test_set):
        """Measure if expert successfully completes task."""
        completed = 0
        for example in test_set:
            result = self.expert(example.task)
            if self.validates(result, example):
                completed += 1
        return completed / len(test_set)

    def measure_tool_efficiency(self, test_set):
        """Measure if expert uses minimal tool calls."""
        total_calls = 0
        for example in test_set:
            result = self.expert(example.task)
            total_calls += len(result.trajectory)
        avg_calls = total_calls / len(test_set)
        return 1.0 / avg_calls  # Lower is better

    def measure_cost(self, test_set):
        """Measure average cost per task."""
        total_cost = 0
        for example in test_set:
            with dspy.settings.configure(track_usage=True):
                result = self.expert(example.task)
                usage = result.get_lm_usage()
                total_cost += calculate_cost(usage)
        return total_cost / len(test_set)
```

---

## Troubleshooting Common Issues

### Issue: "DSPy experts slower than manual"

**Diagnosis:**
- First runs are slow (no cache)
- Complex ReAct reasoning
- Multiple tool calls

**Solution:**
```python
# 1. Enable caching (should be default)
dspy.settings.configure(lm=lm, cache=True)

# 2. Use faster model for simple tasks
simple_lm = dspy.LM('openai/gpt-4o-mini')
complex_lm = dspy.LM('openai/gpt-4o')

class DataExpert(dspy.Module):
    def forward(self, task):
        if self.is_simple(task):
            with dspy.context(lm=simple_lm):
                return self.agent(task=task)
        else:
            with dspy.context(lm=complex_lm):
                return self.agent(task=task)

# 3. Optimize max_iters
agent = dspy.ReAct(signature, tools=[...], max_iters=3)  # Instead of 10
```

### Issue: "MCP tools not being called"

**Diagnosis:**
- Tool signatures unclear
- ReAct not recognizing when to use tools
- Tool descriptions insufficient

**Solution:**
```python
# Improve tool docstrings
def hdf5_analyze(filepath: str) -> dict:
    """Analyze HDF5 file structure and performance.

    Use this when user asks about:
    - HDF5 file optimization
    - Compression strategies
    - Chunking analysis
    - File structure inspection

    Args:
        filepath: Absolute path to HDF5 file (e.g., /data/sim.h5)

    Returns:
        Dict with keys: compression_ratio, chunk_shape, datasets, size_bytes
    """
    # ... implementation
```

### Issue: "Optimization doesn't improve performance"

**Diagnosis:**
- Insufficient training data
- Poor quality metric
- Examples not representative

**Solution:**
```python
# 1. Collect more diverse examples
examples = load_logs() + generate_synthetic() + add_edge_cases()

# 2. Improve metric
def better_metric(example, pred, trace=None):
    # Multi-dimensional
    correctness = check_answer(example, pred)
    efficiency = check_tools(pred.trajectory)
    user_feedback = get_feedback(pred.task_id)

    return (correctness + efficiency + user_feedback) / 3.0

# 3. Use better optimizer
optimizer = dspy.MIPROv2(
    metric=better_metric,
    auto='heavy',  # More compute
    num_trials=100  # More exploration
)
```

### Issue: "Local model quality poor"

**Diagnosis:**
- Local model not optimized
- Prompts too complex for small model
- Missing fine-tuning step

**Solution:**
```python
# Option 1: Use larger local model
local_lm = dspy.LM('ollama_chat/llama3.1:70b')  # Instead of :8b

# Option 2: Fine-tune small model
cloud_lm = dspy.LM('openai/gpt-4o')
local_lm = dspy.LM('ollama_chat/llama3.1:8b')

# Optimize with cloud
with dspy.context(lm=cloud_lm):
    optimizer = dspy.MIPROv2(metric=metric)
    compiled = optimizer.compile(expert, trainset=data)

# Fine-tune local model
with dspy.context(lm=local_lm):
    ft_optimizer = dspy.BootstrapFinetune(metric=metric)
    finetuned = ft_optimizer.compile(
        student=expert,
        teacher=compiled,
        trainset=data
    )

# Result: Local model now competitive with GPT-4o
```

---

## Next Steps

1. **Read this guide thoroughly**
2. **Review code examples** in DSPY_FOR_WARPIO.md
3. **Implement Phase 1** (single expert POC)
4. **Measure baseline vs DSPy** performance
5. **Decide on Phase 2** based on results
6. **Plan optimization** strategy (when to run, budget)
7. **Set up monitoring** (MLflow, metrics)

---

**Document Version:** 1.0
**Last Updated:** 2025-01-17
**Maintainer:** Warpio Team
