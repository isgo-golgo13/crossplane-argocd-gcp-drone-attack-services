use git2::Repository;
use anyhow::Result;
use std::process::Command;

/// Commits and pushes claim files to Git
pub async fn commit_and_push(claims: Vec<String>) -> Result<()> {
    let repo = Repository::open("../")?;
    let mut index = repo.index()?;
    
    for claim in &claims {
        index.add_path(claim.as_ref().unwrap().as_ref())?;
    }
    
    index.write()?;
    let oid = index.write_tree()?;
    let signature = repo.signature()?;
    let parent_commit = repo.head()?.peel_to_commit()?;
    
    let tree = repo.find_tree(oid)?;
    repo.commit(Some("HEAD"), &signature, &signature, "Added new claims", &tree, &[&parent_commit])?;
    
    Command::new("git")
        .args(&["push", "origin", "main"])
        .output()?;
    
    Ok(())
}
