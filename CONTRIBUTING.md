# Contributing to Database Knowledge Base

Thank you for your interest in contributing to the **Database Knowledge Base and Interview Preparation** repository! 

This repository is maintained to the highest standards of technical accuracy, software architecture design, and database engineering rigor.

---

## Code of Conduct & Contribution Standards

1. **Accuracy Over Hype:** Never present theoretical assumptions as factual database engine behavior. All assertions regarding locking, WAL generation, MVCC, and replication must align with vendor-verified engine implementations.
2. **No Broken Links:** Every Markdown link must be a valid, relative path within the repository or an authoritative official documentation URL.
3. **No Empty Files or Placeholders:** Do not submit placeholder files (`TODO`, `TBD`, empty documents). Every file must contain complete, substantive explanations.
4. **Runnable Code Examples:** All SQL commands and Java Spring Boot code must be syntactically valid and thoroughly reviewed.
5. **Standardized Templates:** All new additions must utilize the corresponding template in [`templates/`](templates/):
   - New database concepts: [`concept-template.md`](templates/concept-template.md)
   - Interview questions: [`interview-question-template.md`](templates/interview-question-template.md)
   - Database releases: [`release-note-template.md`](templates/release-note-template.md)
   - Incident runbooks: [`troubleshooting-template.md`](templates/troubleshooting-template.md)
   - Architectural decisions: [`architecture-decision-record-template.md`](templates/architecture-decision-record-template.md)

---

## Pull Request Workflow

1. **Fork the Repository:** Create your topic branch from `main`:
   ```bash
   git checkout -b feature/topic-or-concept-name
   ```
2. **Follow Markdown Conventions:**
   - Use GitHub Flavored Markdown (GFM).
   - Use standard Mermaid fenced code blocks (`mermaid`) for diagrams.
   - Use standard callout blocks (`> [!NOTE]`, `> [!WARNING]`, `> [!IMPORTANT]`, `> [!CAUTION]`).
3. **Validate Links & Syntax:** Ensure all relative Markdown links resolve correctly.
4. **Submit Pull Request:** Provide a clear summary of your technical additions and reference official vendor documentation where applicable.
