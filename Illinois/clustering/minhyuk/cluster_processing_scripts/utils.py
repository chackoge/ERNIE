import json

import click
import matplotlib.pyplot as plt
import numpy as np
import psycopg2

SMALL_SIZE = 12
MEDIUM_SIZE = 18
BIGGER_SIZE = 24

plt.rc("font", size=SMALL_SIZE)          # controls default text sizes
plt.rc("axes", titlesize=SMALL_SIZE)     # fontsize of the axes title
plt.rc("axes", labelsize=MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc("xtick", labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc("ytick", labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc("legend", fontsize=SMALL_SIZE)    # legend fontsize
plt.rc("figure", titlesize=BIGGER_SIZE)


def file_to_dict(clustering):
    '''This function takes in an input clustering of format "<cluster number>SPACE<node id>"
    and returns two python dictionaries that map from cluster number to a list of node ids and
    from a node id to list of cluster numbers.
    '''
    cluster_to_doi_dict = {}
    doi_to_cluster_dict = {}

    with open(clustering, "r") as f:
        for current_line in f:
            [current_cluster_number, doi] = current_line.strip().split()
            if(int(current_cluster_number) not in cluster_to_doi_dict):
                cluster_to_doi_dict[int(current_cluster_number)] = []
            if(doi not in doi_to_cluster_dict):
                doi_to_cluster_dict[doi] = []
            cluster_to_doi_dict[int(current_cluster_number)].append(doi)
            doi_to_cluster_dict[doi].append(int(current_cluster_number))
    for current_doi in doi_to_cluster_dict:
        doi_to_cluster_dict[current_doi] = list(set(doi_to_cluster_dict[current_doi]))
    return {
        "cluster_to_doi_dict": cluster_to_doi_dict,
        "doi_to_cluster_dict": doi_to_cluster_dict,
    }


def save_histogram(x_min, x_max, bin_size, data, y_label, x_label, title, output_prefix):
    plt.clf()
    plt.figure(figsize=(20, 17))
    bins = np.arange(x_min, x_max, bin_size)
    # plt.locator_params(nbins=10)
    plt.xticks(np.linspace(x_min, x_max, 25, dtype=int))
    plt.hist(data, bins=bins, density=False)
    plt.ylabel(y_label)
    plt.xlabel(x_label);
    plt.title(title);
    plt.savefig(output_prefix + ".png", bbox_inches="tight")
    plt.close()


def save_scatter(x_data, y_data, x_label, y_label, title, output_prefix, y_min=0, add_x_y_line=False, log_log=False):
    # plt.locator_params(nbins=10)
    plt.clf()
    plt.figure(figsize=(20, 17))
    plt.xticks(np.linspace(0, max(x_data), 25, dtype=int))
    plt.scatter(x_data, y_data)
    if(add_x_y_line):
        print("adding y=x")
        plt.plot(x_data, x_data, color="red", label="y=x")
    plt.ylim(ymin=y_min)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.title(title)
    plt.savefig(output_prefix + ".png", bbox_inches="tight")
    plt.close()
