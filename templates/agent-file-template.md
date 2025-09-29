# [PROJECT NAME] Development Guidelines

Auto-generated from all feature plans. Last updated: [DATE]

## Active Technologies
[EXTRACTED FROM ALL PLAN.MD FILES]

## Project Structure
```
[ACTUAL STRUCTURE FROM PLANS]
```

## Commands
[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES]

## Code Style
[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE]

## Recent Changes
[LAST 3 FEATURES AND WHAT THEY ADDED]

## PRP Alignment
- Specifications, plans, tasks, and PRPs must stay synchronized—always regenerate artifacts when upstream documents change.
- Treat the PRP as the authoritative runbook: Goal/Why → Curated Context → Implementation Blueprint → Validation Gates.
- Every deliverable must cite the evidence source (spec section, plan decision, metric, or test) that justifies it.
- Maintain the `/prps` directory so Factory Droid and other agents can prime themselves with the latest Product Requirement Prompt.

## Engineering Principles

**Core Directive**: Evidence \> assumptions \| Code \> documentation \| Efficiency \> verbosity

### Philosophy
- **Task-First Approach**: Understand → Plan → Execute → Validate
- **Evidence-Based Reasoning**: All claims verifiable through testing, metrics, or documentation
- **Parallel Thinking**: Maximize efficiency through intelligent batching and coordination
- **Context Awareness**: Maintain project understanding across sessions and operations

### SOLID
- **Single Responsibility**: Each component has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Derived classes substitutable for base classes
- **Interface Segregation**: Don't depend on unused interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions

### Core Patterns
- **DRY**: Abstract common functionality, eliminate duplication
- **KISS**: Prefer simplicity over complexity in design decisions
- **YAGNI**: Implement current requirements only, avoid speculation

### Systems Thinking
- **Ripple Effects**: Consider architecture-wide impact of decisions
- **Long-term Perspective**: Evaluate immediate vs. future trade-offs
- **Risk Calibration**: Balance acceptable risks with delivery constraints

### Decision Framework
- **Measure First**: Base optimization on measurements, not assumptions
- **Hypothesis Testing**: Formulate and test systematically
- **Source Validation**: Verify information credibility
- **Bias Recognition**: Account for cognitive biases

### Trade-off Analysis
- **Temporal Impact**: Immediate vs. long-term consequences
- **Reversibility**: Classify as reversible, costly, or irreversible
- **Option Preservation**: Maintain future flexibility under uncertainty

### Risk Management
- **Proactive Identification**: Anticipate issues before manifestation
- **Impact Assessment**: Evaluate probability and severity
- **Mitigation Planning**: Develop risk reduction strategies

### Quality Philosophy
- **Functional**: Correctness, reliability, feature completeness
- **Structural**: Code organization, maintainability, technical debt
- **Performance**: Speed, scalability, resource efficiency
- **Security**: Vulnerability management, access control, data protection

### Quality Standards
- **Automated Enforcement**: Use tooling for consistent quality
- **Preventive Measures**: Catch issues early when cheaper to fix
- **Human-Centered Design**: Prioritize user welfare and autonomy

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->