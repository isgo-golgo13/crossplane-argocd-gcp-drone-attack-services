mod git;
mod crossplane;
mod config;

use clap::{Parser, Subcommand};
use crossplane::generate_claim;
use git::commit_and_push;
use anyhow::Result;

/// CLI for requesting GCP Infra with Crossplane via GitOps
#[derive(Parser)]
#[command(name = "crossplane-cli")]
#[command(version = "1.0")]
#[command(about = "Provision GCP Infra through Crossplane and ArgoCD", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Create a new infrastructure claim and push to Git
    Request {
        #[arg(short, long)]
        project_name: String,
        #[arg(short, long)]
        gke: bool,
        #[arg(short, long)]
        cloudrun: bool,
        #[arg(short, long)]
        appengine: bool,
        #[arg(short, long)]
        apigee: bool,
        #[arg(short, long)]
        spanner: bool,
        #[arg(short, long)]
        firestore: bool,
        #[arg(short, long)]
        pubsub: bool,
        #[arg(short, long)]
        networking: bool,
        #[arg(short, long)]
        eventarc: bool,
        #[arg(short, long)]
        iam: bool,
    },
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Request {
            project_name,
            gke,
            cloudrun,
            appengine,
            apigee,
            spanner,
            firestore,
            pubsub,
            networking,
            eventarc,
            iam,
        } => {
            let mut claims = Vec::new();

            if *gke {
                claims.push(generate_claim("gcp-gke", project_name));
            }
            if *cloudrun {
                claims.push(generate_claim("gcp-cloudrun", project_name));
            }
            if *appengine {
                claims.push(generate_claim("gcp-appengine", project_name));
            }
            if *apigee {
                claims.push(generate_claim("gcp-apigee", project_name));
            }
            if *spanner {
                claims.push(generate_claim("gcp-spanner", project_name));
            }
            if *firestore {
                claims.push(generate_claim("gcp-firestore", project_name));
            }
            if *pubsub {
                claims.push(generate_claim("gcp-pubsub", project_name));
            }
            if *networking {
                claims.push(generate_claim("gcp-networking", project_name));
            }
            if *eventarc {
                claims.push(generate_claim("gcp-eventarc", project_name));
            }
            if *iam {
                claims.push(generate_claim("gcp-iam", project_name));
            }

            commit_and_push(claims).await?;
        }
    }

    Ok(())
}
