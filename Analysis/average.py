import numpy as np
import argparse
import warnings
import sys

def arg_parse():
  parser = argparse.ArgumentParser()
  parser.add_argument('-f', '--file', dest = 'data_file', required = True, help = 'input raw data in one column')
  parser.add_argument('-d', '--dimension', dest = 'dims', nargs = '+', type = int, required = True, help = 'dimension of data array')
  parser.add_argument('-x', '--axis', dest = 'ave_axis', type = int, required = True, help = 'the dimension along which to average')
  parser.add_argument('-v', '--verbose', action = 'store_true', help = 'print data matrix before averaging')
  args = parser.parse_args()
  return args.data_file, args.dims, args.ave_axis, args.verbose

def reject_outliers(data, m = 2.):
  return data[abs(data - np.mean(data)) < m * np.std(data)]

def smooth1d(data, m = 2.):
  data_wo_outliers = reject_outliers(data, m)
  outliers = np.setdiff1d(data, data_wo_outliers)
  # I expect to see RuntimeWarnings in this block
  with warnings.catch_warnings():
    warnings.simplefilter("ignore", category = RuntimeWarning)
    ave = np.nanmean(data_wo_outliers)
  for outlier in outliers:
    np.place(data, data == outlier, ave)
  return data

def smooth(data, rep, m = 2.):
  if len(data) % rep != 0:
    print("Length of data is not a multiple of number of repetition")
  else:
    idx = 0
    while (idx < len(data)):
      smooth1d(data[idx : idx + rep], m)
      idx += rep
  return data

if __name__== "__main__":
  data_file, dims, ave_axis, verbose = arg_parse();

  with open(data_file) as f:
    data = f.read().split('\n')

  del data[-1]
  data = [np.double(x) for x in data]
  print("Length of data: " + str(len(data)))
  data = np.array(data)
  shape = dims
  rep = shape[ave_axis]
  data = smooth(data, rep, 1)
  data_mat = data.reshape(shape)
  # I expect to see RuntimeWarnings in this block
  with warnings.catch_warnings():
    warnings.simplefilter("ignore", category = RuntimeWarning)
    data_mat[data_mat < 0] = 'nan'
    if verbose:
      print(data_mat)
    ave = np.nanmean(data_mat, axis = ave_axis)
    stddev = np.nanstd(data_mat, axis = ave_axis) / ave * 100

  print("Average:")
  if len(ave.shape) > 2:
    for n in ave:
      np.savetxt(sys.stdout, n, fmt = '%10.4f')
      print('')
  else:
    np.savetxt(sys.stdout, ave, fmt = '%10.4f')

  print("Standard deviation (in percentage):")
  if len(ave.shape) > 2:
    for n in stddev:
      np.savetxt(sys.stdout, n, fmt = "%10.4f")
      print('')
  else:
    np.savetxt(sys.stdout, stddev, fmt = "%10.4f")
